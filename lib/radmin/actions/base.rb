require 'radmin/actions'
require 'radmin/utils/bindable'
require 'radmin/utils/configurable'
require 'singleton'

module Radmin
  module Actions
    class Base
      include Radmin::Utils::Bindable
      include Radmin::Utils::Configurable
      include Singleton

      register_property :statistics do
        false
      end

      register_property :link_icon do
        nil
      end

      register_property :link_text do
        nil
      end

      register_property :enabled? do
        true

        # bindings[:abstract_model].nil? || (
        # (only.nil? || [only].flatten.collect(&:to_s).include?(bindings[:abstract_model].to_s)) &&
        #     ![except].flatten.collect(&:to_s).include?(bindings[:abstract_model].to_s) &&
        #     !bindings[:abstract_model].config.excluded?
        # )
      end

      # Should the action be visible
      register_property :visible? do
        link_icon.present? || link_text.present?

        # authorized?
      end

      register_property :authorized? do
        true

        # enabled? && (
        # bindings[:controller].try(:authorization_adapter).nil? || bindings[:controller].authorization_adapter.authorized?(authorization_key, bindings[:abstract_model], bindings[:object])
        # )
      end

      # Is the action acting on the root level (Example: /admin/contact)
      register_property :root? do
        false
      end

      # Is the action on a model scope (Example: /admin/team/export)
      register_property :collection? do
        false
      end

      # Is the action on an object scope (Example: /admin/team/1/edit)
      register_property :member? do
        false
      end

      # Model scoped actions only. You will need to handle params[:bulk_ids] in controller
      register_property :bulkable? do
        false
      end

      # Scoped by filters. You will need to handle params[:f] in controller
      register_property :scopeable? do
        false
      end

      # # Render via pjax?
      # register_attribute  :pjax? do
      #   true
      # end

      # This block is evaluated in the context of the controller when action is called
      # You can access:
      # - @objects if you're on a model scope
      # - @abstract_model & @model_config if you're on a model or object scope
      # - @object if you're on an object scope
      register_property :controller do
        proc do
          render action: @action.template_name
        end
      end

      # View partial name (called in default :controller block)
      register_property :template_name do
        key.to_sym
      end

      # For Cancan and the like
      register_property :authorization_key do
        key.to_sym
      end

      # List of methods allowed. Note that you are responsible for correctly handling them in :controller block
      register_property :http_methods do
        [:get]
      end

      # Url fragment
      register_property :route_fragment do
        custom_key.to_s
      end

      # Controller action name
      register_property :action_name do
        custom_key.to_sym
      end

      # I18n key
      register_property :i18n_key do
        key
      end

      # User should override only custom_key (action name and route fragment change, allows for duplicate actions)
      register_property :custom_key do
        key
      end

      # Breadcrumb parent
      register_property :breadcrumb_parent do
        if root?
          [:dashboard]
        elsif collection?
          [:index, bindings[:abstract_model]]
        elsif member?
          [:show, bindings[:abstract_model], bindings[:object]]
        end
      end


      def key
        self.class.key
      end

      def self.key
        name.to_s.demodulize.underscore.to_sym
      end
    end
  end
end