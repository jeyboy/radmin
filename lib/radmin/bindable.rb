require 'active_support/concern'

module Radmin
  module Bindable
    extend ActiveSupport::Concern

    included do
      # scope :disabled, -> { where(disabled: true) }

      unless defined? :bindings
        define_method :bindings do
          @bindings
        end
      end
    end

    class_methods do
      def with_bindings(**args)
        @bindings = args
      end
    end
  end
end