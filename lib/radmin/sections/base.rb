require 'radmin/utils/configurable'
require 'radmin/utils/groupable'
require 'radmin/utils/scopeable'

module Radmin
  module Sections
    class Base
      include Radmin::Utils::Configurable
      include Radmin::Utils::Groupable
      include Radmin::Utils::Scopeable

      # def initialize
      #
      # end

      register_property :links do
        []
      end
    end
  end
end