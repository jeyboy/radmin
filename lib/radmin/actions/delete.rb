require 'radmin/actions/base'

module Radmin
  module Actions
    class Delete < Radmin::Actions::Base
      Radmin::Actions::register_action(self)

      register_property :member? do
        true
      end

      register_property :http_methods do
        [:get, :delete]
      end

      register_property :route_fragment do
        'delete'
      end

      register_property :controller do
        proc do
          # if request.get? # DELETE
          #
          #   respond_to do |format|
          #     format.html { render @action.template_name }
          #     format.js   { render @action.template_name, layout: false }
          #   end
          #
          # elsif request.delete? # DESTROY
          #
          #   redirect_path = nil
          #   @auditing_adapter && @auditing_adapter.delete_object(@object, @abstract_model, _current_user)
          #   if @object.destroy
          #     flash[:success] = t('admin.flash.successful', name: @model_config.label, action: t('admin.actions.delete.done'))
          #     redirect_path = index_path
          #   else
          #     flash[:error] = t('admin.flash.error', name: @model_config.label, action: t('admin.actions.delete.done'))
          #     redirect_path = back_or_index
          #   end
          #
          #   redirect_to redirect_path
          #
          # end
        end
      end

      register_property :link_icon do
        'icon-remove'
      end
    end
  end
end