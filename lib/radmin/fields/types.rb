module Radmin
  module Fields
    module Types
      @@field_types = {}

      def self.load(type)
        @@field_types[type.to_sym] || raise("Unsupported field datatype: #{type}")
      end

      def self.register(type, klass = nil)
        if klass.nil? && type.is_a?(Class)
          klass = type
          type = klass.name.to_s.demodulize.underscore
        end
        @@field_types[type.to_sym] = klass
      end

      require 'radmin/fields/types/all'
    end
  end
end
