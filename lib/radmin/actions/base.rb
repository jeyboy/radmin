require 'radmin/actions'
require 'radmin/bindable'
require 'singleton'

module Radmin
  module Actions
    class Base
      include Radmin::Bindable
      include Singleton

      def statistics
        false
      end

      def link_icon
        nil
      end

      def link_text
        nil
      end

      def enabled?
        true

        # bindings[:abstract_model].nil? || (
        # (only.nil? || [only].flatten.collect(&:to_s).include?(bindings[:abstract_model].to_s)) &&
        #     ![except].flatten.collect(&:to_s).include?(bindings[:abstract_model].to_s) &&
        #     !bindings[:abstract_model].config.excluded?
        # )
      end

      # Should the action be visible
      def visible?
        link_icon.present? || link_text.present?

        # authorized?
      end

      def authorized?
        true

        # enabled? && (
        # bindings[:controller].try(:authorization_adapter).nil? || bindings[:controller].authorization_adapter.authorized?(authorization_key, bindings[:abstract_model], bindings[:object])
        # )
      end

      # Is the action acting on the root level (Example: /admin/contact)
      def root?
        false
      end

      # Is the action on a model scope (Example: /admin/team/export)
      def collection?
        false
      end

      # Is the action on an object scope (Example: /admin/team/1/edit)
      def member?
        false
      end

      # Model scoped actions only. You will need to handle params[:bulk_ids] in controller
      def bulkable?
        false
      end

      # Scoped by filters. You will need to handle params[:f] in controller
      def scopeable?
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
      def controller
        proc do
          render action: @action.template_name
        end
      end

      # View partial name (called in default :controller block)
      def template_name
        key.to_sym
      end

      # For Cancan and the like
      def authorization_key
        key.to_sym
      end

      # List of methods allowed. Note that you are responsible for correctly handling them in :controller block
      def http_methods
        [:get]
      end

      # Url fragment
      def route_fragment
        custom_key.to_s
      end

      # Controller action name
      def action_name
        custom_key.to_sym
      end

      # I18n key
      def i18n_key
        key
      end

      # User should override only custom_key (action name and route fragment change, allows for duplicate actions)
      def custom_key
        key
      end

      # Breadcrumb parent
      def breadcrumb_parent
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