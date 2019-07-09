require 'active_support/concern'

module Radmin
  module Utils
    module Scopeable
      def scopes(*list)
        i = 0
      end

      def identify_scope_arg(obj_name, rel_names = nil)
        mtds = Radmin::Config::scopes

        return unless mtds.present?

        identify_entry(mtds[current_action], obj_name, rel_names).presence ||
          identify_entry(mtds[nil].presence || mtds[:nil], obj_name, rel_names).presence
      end
    end
  end
end