module Radmin
  class MainController < Radmin::ApplicationController
    include ActionView::Helpers::TextHelper
    include Radmin::MainHelper

    layout :get_layout

    before_action :get_model, except: Radmin::Actions.list(:root).collect(&:action_name)
    before_action :get_object, only: Radmin::Actions.list(:member).collect(&:action_name)
    before_action :check_for_cancel

    Radmin::Actions.list.each do |act|
      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{act.action_name}
          @current_action = action(params[:action])
          @current_action.with_bindings(bindings)
          fail(ActionNotAllowed) unless current_action || current_action.enabled?
          @authorization_adapter.try(:authorize, current_action.action_name, current_model, @object)
          @current_model.with_bindings(bindings)
          @page_name = wording_for(:title)
          instance_eval &current_action.controller
        end
      EOS
    end

    def bulk_action
      send(params[:bulk_action]) if
        params[:bulk_action].in?(Radmin::Actions.list(:bulkable?).collect(&:route_fragment))
    end

    def list_entries(abstract_model = current_model, auth_scope_key = :index, additional_scope = get_association_scope_from_params, pagination = !(params[:associated_collection] || params[:all] || params[:bulk_ids]))
      scope = abstract_model.scoped

      auth_scope = @authorization_adapter&.query(auth_scope_key, abstract_model)
      scope = scope.merge(auth_scope) if auth_scope

      scope = scope.instance_eval(&additional_scope) if additional_scope

      get_collection(abstract_model, scope, pagination)
    end

    private

    def get_layout
      "radmin/#{request.xhr? ? 'content' : 'application'}"
    end

    def back_or_index
      params[:return_to].presence && params[:return_to].include?(request.host) && (params[:return_to] != request.fullpath) ? params[:return_to] : index_path
    end

    def redirect_to_on_success
      notice = I18n.t('admin.flash.successful', name: current_model.label, action: I18n.t("admin.actions.#{current_action.key}.done"))
      if params[:_add_another]
        redirect_to new_path(return_to: params[:return_to]), flash: {success: notice}
      elsif params[:_add_edit]
        redirect_to edit_path(id: @object.id, return_to: params[:return_to]), flash: {success: notice}
      else
        redirect_to back_or_index, flash: {success: notice}
      end
    end

    def handle_save_error(whereto = :new)
      flash.now[:error] = I18n.t('admin.flash.error', name: current_model.label, action: I18n.t("admin.actions.#{current_action.key}.done").html_safe).html_safe
      flash.now[:error] += %(<br>- #{@object.errors.full_messages.join('<br>- ')}).html_safe

      respond_to do |format|
        format.html { render whereto, status: :not_acceptable }
        format.js   { render whereto, layout: false, status: :not_acceptable }
      end
    end

    def check_for_cancel
      return unless params[:_continue] || (params[:bulk_action] && !params[:bulk_ids])
      redirect_to(back_or_index, notice: I18n.t('admin.flash.noaction'))
    end

    def visible_fields(target_action, model_config = current_model)
      model_config.send(target_action).with_bindings(controller: self, view: view_context, object: @object).visible_fields
    end

    def sanitize_params_for!(target_action, model_config = current_model, target_params = params[current_model.param_key])
      return unless target_params.present?

      fields = visible_fields(target_action, model_config)

      allowed_methods = fields.collect(&:allowed_methods).flatten.uniq.collect(&:to_s) << 'id' << '_destroy'

      fields.each { |field| field.parse_input(target_params) }

      target_params.slice!(*allowed_methods)

      target_params.permit! if target_params.respond_to?(:permit!)

      fields.select(&:nested_form).each do |association|
        children_params = association.multiple? ? target_params[association.name].try(:values) : [target_params[association.name]].compact
        (children_params || []).each do |children_param|
          sanitize_params_for!(:nested, association.associated_model_config, children_param)
        end
      end
    end

    def get_collection(abstract_model, scope, pagination)
      associations = abstract_model.list.fields.select { |f| f.try(:eager_load?) }.collect { |f| f.association.name }

      options = {}
      options = options.merge(page: (params[Kaminari.config.param_name] || 1).to_i, per: (params[:per] || abstract_model.list.items_per_page)) if pagination
      options = options.merge(include: associations) unless associations.blank?
      # options = options.merge(get_sort_hash(abstract_model))
      options = options.merge(query: params[:query]) if params[:query].present?

      if params[:f].present?
        filters =
          if params[:f].is_a?(ActionController::Parameters)
            params[:f].permit!.to_hash
          else
            params[:f]
          end
        
        options = options.merge(filters: filters)
      end
      
      options = options.merge(bulk_ids: params[:bulk_ids]) if params[:bulk_ids]

      abstract_model.all(options, scope)
    end

    def get_association_scope_from_params
      return nil unless params[:associated_collection].present?

      source_abstract_model = Radmin::Config.model(to_model_name(params[:source_abstract_model]))

      source_model_config = source_abstract_model.config
      source_object = source_abstract_model.get(params[:source_object_id])
      action_name = params[:current_action].in?(%w(create update)) ? params[:current_action] : 'edit'

      @association = source_model_config.send(action_name).find_field(params[:associated_collection]).with_bindings(controller: self, object: source_object)

      @association.associated_collection_scope
    end


    def get_sort_hash(abstract_model)
      field = abstract_model.list.find_field(params[:sort])

      params[:sort] = params[:sort_reverse] = nil unless field
      params[:sort] ||= abstract_model.list.sort_by.to_s
      params[:sort_reverse] ||= 'false'

      column = begin
        if field.nil? || field.sortable == true # use params[:sort] on the base table
          "#{abstract_model.table_name}.#{params[:sort]}"
        elsif field.sortable == false # use default sort, asked field is not sortable
          "#{abstract_model.table_name}.#{abstract_model.list.sort_by}"
        elsif (field.sortable.is_a?(String) || field.sortable.is_a?(Symbol)) && field.sortable.to_s.include?('.') # just provide sortable, don't do anything smart
          field.sortable
        elsif field.sortable.is_a?(Hash) # just join sortable hash, don't do anything smart
          "#{field.sortable.keys.first}.#{field.sortable.values.first}"
        elsif field.association? # use column on target table
          "#{field.abstract_model.table_name}.#{field.sortable}"
        else # use described column in the field conf.
          "#{abstract_model.table_name}.#{field.sortable}"
        end
      end

      reversed_sort = (field ? field.sort_reverse? : abstract_model.list.sort_reverse?)
      {sort: column, sort_reverse: (params[:sort_reverse] == reversed_sort.to_s)}
    end
  end
end