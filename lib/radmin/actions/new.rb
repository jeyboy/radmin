require 'radmin/actions/base'

module Radmin
  module Actions
    class New < Radmin::Actions::Base
      Radmin::Actions::register(self)

      register_property :collection? do
        true
      end

      register_property :http_methods do
        [:get, :post]
      end

      register_property :controller do
        proc do
          # if request.get? # NEW
          #
          #   @object = @abstract_model.new
          #   @authorization_adapter && @authorization_adapter.attributes_for(:new, @abstract_model).each do |name, value|
          #     @object.send("#{name}=", value)
          #   end
          #   if object_params = params[@abstract_model.param_key]
          #     sanitize_params_for!(request.xhr? ? :modal : :create)
          #     @object.set_attributes(@object.attributes.merge(object_params.to_h))
          #   end
          #   respond_to do |format|
          #     format.html { render current_action.template_name }
          #     format.js   { render current_action.template_name, layout: false }
          #   end
          #
          # elsif request.post? # CREATE
          #
          #   @modified_assoc = []
          #   @object = @abstract_model.new
          #   sanitize_params_for!(request.xhr? ? :modal : :create)
          #
          #   @object.set_attributes(params[@abstract_model.param_key])
          #   @authorization_adapter && @authorization_adapter.attributes_for(:create, @abstract_model).each do |name, value|
          #     @object.send("#{name}=", value)
          #   end
          #
          #   if @object.save
          #     @auditing_adapter && @auditing_adapter.create_object(@object, @abstract_model, _current_user)
          #     respond_to do |format|
          #       format.html { redirect_to_on_success }
          #       format.js   { render json: {id: @object.id.to_s, label: @model_config.with(object: @object).object_label} }
          #     end
          #   else
          #     handle_save_error
          #   end
          #
          # end
        end
      end

      register_property :link_icon do
        'plus'
      end
    end
  end
end