module Radmin
  class FormBuilder < ::ActionView::Helpers::FormBuilder
    # include ::NestedForm::BuilderMixin
    include ::Radmin::ApplicationHelper
    include ::FontAwesome::Rails::IconHelper

    delegate :content_tag, to: :@template

    def generate(options = {})
      without_field_error_proc_added_div do
        @action_param = (options[:action].presence || @template.controller.params[:action]).to_sym
        @target_model = options[:current_model].presence || @template.current_model

        options.reverse_merge!(
          action: @action_param,
          current_model: @target_model,
          nested_in: false,
          buttons_location: @target_model.send(@action_param).submit_buttons_location
        )

        groups = visible_groups(options[:current_model], generator_action(options[:action], options[:nested_in]))

        buttons =
          (options[:nested_in] ? '' : @template.render(partial: 'radmin/main/submit_buttons'))

        (options[:buttons_location][:top] ? buttons : '').html_safe +
          groups.collect do |_, fieldset|
            fieldset_for fieldset, options[:nested_in]
          end.join.html_safe +
            (options[:buttons_location][:bottom] ? buttons : '').html_safe
      end
    end

    def fieldset_for(fieldset, nested_in)
      fieldset.with_bindings(
        action: @action_param,
        abstract_model: @target_model,
        form: self,
        object: @object,
        view: @template,
        controller: @template.controller,
      )

      fields = fieldset.visible_fields({id: false})

      return if fields.empty?

      @template.content_tag :fieldset do
        <<-CONTENT
          #{ @template.content_tag(:legend, "#{fa_icon("chevron-#{(fieldset.open? ? 'down' : 'right')}", type: :solid)} #{fieldset.label}".html_safe) if fieldset.name.present? }
          #{ @template.content_tag(:p, fieldset.help) if fieldset.help.present? }
          #{ fields.collect { |field| field_wrapper_for(field, nested_in) }.join }
        CONTENT
          .html_safe
      end
    end

    def field_wrapper_for(field, nested_in)
      if field.label
        # do not show nested field if the target is the origin
        unless nested_field_association?(field, nested_in)
          @template.content_tag(:div, class: "row form-group control-group #{field.type_css_class} #{field.css_class} #{'error' if field.errors.present?}", id: "#{dom_id(field)}_field") do
            label_for(field) +
              (field.nested_form ? field_for(field) : input_for(field))
          end
        end
      else
        field.nested_form ? field_for(field) : input_for(field)
      end
    end

    def label_for(field)
      has_add_info = field.additional_info.present?

      target_classes = 'col-md-3 col-sm-4'

      target_label =
        label(field.name, capitalize_first_letter(field.label), class: "#{target_classes unless has_add_info} control-label")

      if has_add_info
        @template.content_tag(:div, class: target_classes) do
          target_label +
            @template.content_tag(:p, field.additional_info, class: 'add_info')
        end
      end || target_label
    end

    def input_for(field)
      css = "col-sm-8 col-md-9 controls #{'has-error' if field.errors.present?}"

      @template.content_tag(:div, class: css) do
        field_for(field) + errors_for(field) + help_for(field)
      end
    end

    def errors_for(field)
      field.errors.present? ? @template.content_tag(:span, field.errors.to_sentence, class: 'help-inline text-danger') : ''.html_safe
    end

    def help_for(field)
      field.help.present? ? @template.content_tag(:span, field.help, class: 'help-block') : ''.html_safe
    end

    def field_for(field)
      field.read_only ? @template.content_tag(:div, field.pretty_value, class: 'form-control-static') : field.render
    end

    # def object_infos
    #   model_config = RailsAdmin.config(object)
    #   model_label = model_config.label
    #   object_label = begin
    #     if object.new_record?
    #       I18n.t('admin.form.new_model', name: model_label)
    #     else
    #       object.send(model_config.object_label_method).presence || "#{model_config.label} ##{object.id}"
    #     end
    #   end
    #   %(<span style="display:none" class="object-infos" data-model-label="#{model_label}" data-object-label="#{CGI.escapeHTML(object_label.to_s)}"></span>).html_safe
    # end

    def jquery_namespace(field)
      %(#{'#modal ' if @template.controller.params[:modal]}##{dom_id(field)}_field)
    end

    def dom_id(field)
      (@dom_id ||= {})[field.name] ||=
        [
          @object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, '_').sub(/_$/, ''),
          options[:index],
          field.name,
        ].reject(&:blank?).join('_')
    end

    def dom_name(field)
      (@dom_name ||= {})[field.name] ||= %(#{@object_name}#{options[:index] && "[#{options[:index]}]"}[#{field.name}]#{field.is_a?(Config::Fields::Association) && field.multiple? ? '[]' : ''})
    end

  protected

    def generator_action(action, nested)
      if nested
        action = :nested
      elsif @template.request.format == 'text/javascript'
        action = :modal
      end

      action
    end

    def visible_groups(model_config, action)
      model_config.send(action).with_bindings(
        form: self,
        object: @object,
        view: @template,
        controller: @template.controller,
      ).visible_groups(has_visible_fields: false)
    end

    def without_field_error_proc_added_div
      default_field_error_proc = ::ActionView::Base.field_error_proc
      begin
        ::ActionView::Base.field_error_proc = proc { |html_tag, _instance| html_tag }
        yield
      ensure
        ::ActionView::Base.field_error_proc = default_field_error_proc
      end
    end

  private
    def nested_field_association?(field, nested_in)
      field.inverse_of.presence && nested_in.presence &&
        field.inverse_of == nested_in.name &&
          (@template.current_model == field.abstract_model ||
            field.name == nested_in.inverse_of)
    end
  end
end
