require 'radmin/utils/configurable'
require 'radmin/utils/groupable'
require 'radmin/utils/scopeable'
require 'radmin/utils/has_fields'

module Radmin
  module Sections
    class Base
      include Radmin::Utils::Configurable
      include Radmin::Utils::Groupable
      include Radmin::Utils::Scopeable
      include Radmin::Utils::HasFields

      attr_reader :abstract_model

      register_property :links do
        []
      end
      
      def initialize(abstract_model)
        @abstract_model = abstract_model
      end
      
      def bindings
        abstract_model.bindings
      end

      def with_bindings(args)
        abstract_model.append_bindings(args)
        self
      end

      def key
        self.class.key
      end

      def self.key
        name.demodulize.underscore
      end
    end
  end
end