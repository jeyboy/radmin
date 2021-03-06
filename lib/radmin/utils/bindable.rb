require 'active_support/concern'

module Radmin
  module Utils
    module Bindable
      extend ActiveSupport::Concern

      included do
        # scope :disabled, -> { where(disabled: true) }

        unless respond_to? :bindings
          define_method :bindings do
            @bindings || {}
          end
        end
      end


      def with_bindings(**args)
        @bindings = args
        self
      end

      def append_bindings(**args)
        @bindings = (@bindings || {}).merge(args)
        self
      end

      def current_action
        raise 'No action' unless bindings[:action].present?
        "#{bindings[:action]}_act"
      end
    end
  end
end