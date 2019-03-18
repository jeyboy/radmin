require 'radmin/actions/base'

module Radmin
  module Actions
    class BulkDelete < Radmin::Actions::Base
      Radmin::Actions::register_action(self)

      register_property :collection? do
        true
      end

      register_property :bulkable? do
        true
      end

      register_property :scopeable? do
        true
      end

      register_property :http_methods do
        [:post, :delete]
      end

      register_property :route_fragment do
        'delete'
      end

      register_property :controller do
        proc do
          # if request.post? # BULK DELETE
          #   @objects = list_entries(@model_config, :destroy)
          #
          #   if @objects.blank?
          #     flash[:error] = t('admin.flash.error', name: pluralize(0, @model_config.label), action: t('admin.actions.delete.done'))
          #     redirect_to index_path
          #   else
          #     render @action.template_name
          #   end
          #
          # elsif request.delete? # BULK DESTROY
          #
          #   destroyed = nil
          #   not_destroyed = nil
          #
          #   unless params[:bulk_ids].blank?
          #     @objects = list_entries(@model_config, :destroy)
          #     unless @objects.blank?
          #       processed_objects = @abstract_model.destroy(@objects)
          #       destroyed = processed_objects.select(&:destroyed?)
          #       not_destroyed = processed_objects - destroyed
          #       destroyed.each do |object|
          #         @auditing_adapter && @auditing_adapter.delete_object(object, @abstract_model, _current_user)
          #       end
          #     end
          #   end
          #
          #   if destroyed.nil?
          #     flash[:error] = t('admin.flash.error', name: pluralize(0, @model_config.label), action: t('admin.actions.delete.done'))
          #   else
          #     flash[:success] = t('admin.flash.successful', name: pluralize(destroyed.count, @model_config.label), action: t('admin.actions.delete.done')) unless destroyed.empty?
          #     flash[:error] = t('admin.flash.error', name: pluralize(not_destroyed.count, @model_config.label), action: t('admin.actions.delete.done')) unless not_destroyed.empty?
          #   end
          #   redirect_to back_or_index
          # end
        end
      end

      register_property :link_icon do
        'icon-remove'
      end
    end
  end
end