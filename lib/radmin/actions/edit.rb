require 'radmin/actions/base'

module Radmin
  module Actions
    class Edit < Radmin::Actions::Base
      Radmin::Actions::register(self)

      register_property :member? do
        true
      end

      register_property :http_methods do
        [:get, :put]
      end

      register_property :controller do
        proc do
          # if request.get? # EDIT
          #
          #   respond_to do |format|
          #     format.html { render @action.template_name }
          #     format.js   { render @action.template_name, layout: false }
          #   end
          #
          # elsif request.put? # UPDATE
          #   sanitize_params_for!(request.xhr? ? :modal : :update)
          #
          #   @object.set_attributes(params[@abstract_model.param_key])
          #   @authorization_adapter && @authorization_adapter.attributes_for(:update, @abstract_model).each do |name, value|
          #     @object.send("#{name}=", value)
          #   end
          #   changes = @object.changes
          #   if @object.save
          #     @auditing_adapter && @auditing_adapter.update_object(@object, @abstract_model, _current_user, changes)
          #     respond_to do |format|
          #       format.html { redirect_to_on_success }
          #       format.js { render json: {id: @object.id.to_s, label: @model_config.with(object: @object).object_label} }
          #     end
          #   else
          #     handle_save_error :edit
          #   end
          #
          # end
        end
      end

      register_property :link_icon do
        'pencil-alt'
      end
    end
  end
end