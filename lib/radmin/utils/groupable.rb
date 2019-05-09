require 'active_support/concern'
require 'radmin/utils/has_fields'
require 'radmin/groups/base'

module Radmin
  module Utils
    module Groupable
      DEFAULT_GROUP = :default

      def get_group(key, name = nil, &block)
        name = key.underscore if name.nil? && key != DEFAULT_GROUP

        _groups[key] ||= Radmin::Groups::Base.new(self, name)
        _groups[key].instance_eval(&block) if block
        _groups[key]
      end
      
      def visible_groups(has_visible_fields: true)
        _groups.select do |group_key, group|
          #   with_bindings()
          group.visible? && (!has_visible_fields || (has_visible_fields && group.visible_fields.present?))
        end
      end
      
      protected

      def _groups
        @groups ||= {}
      end
    end
  end
end