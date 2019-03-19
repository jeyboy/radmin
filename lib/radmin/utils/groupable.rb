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

      protected

      def _groups
        @groups ||= {}
      end
    end
  end
end