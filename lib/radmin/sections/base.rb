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

      def initialize(abstract_model)
        @abstract_model = abstract_model

        group(DEFAULT_GROUP)
      end

      register_property :links do
        []
      end
    end
  end
end