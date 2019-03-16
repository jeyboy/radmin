require 'active_support/concern'

module Radmin
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

    class_methods do
      def with_bindings(**args)
        @bindings = args
      end

      def append_bindings(**args)
        @bindings = (@bindings || {}).merge(args)
      end
    end
  end
end