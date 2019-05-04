require 'active_support/concern'
require 'radmin/utils/has_fields'
require 'radmin/groups/base'

module Radmin
  module Utils
    module Groupable
      DEFAULT_GROUP = :default

      def group(key, name = nil, &block)
        name = key.underscore if name.nil? && key != DEFAULT_GROUP

        _groups[key] ||= Radmin::Groups::Base.new(self, name)
        _groups[key].instance_eval(&block) if block
      end

      def visible_groups
        _groups.select do |group_key, group|
          #   with_bindings()
          group.visible? && group.visible_fields.present?
        end
      end
      
      protected

      def _groups
        @groups ||= {}
      end
    end
  end
end