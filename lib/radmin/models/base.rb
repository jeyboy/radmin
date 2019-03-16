require 'radmin/utils/configurable'
require 'radmin/sections'

module Radmin
  module Models
    class Base
      include Radmin::Utils::Configurable
      include Radmin::Sections

      register_property :navigation_label do
        # @navigation_label ||= begin
        #   if (parent_module = abstract_model.model.parent) != Object
        #     parent_module.to_s
        #   end
        # end
      end

      register_property :navigation_icon do
        nil
      end
    end
  end
end