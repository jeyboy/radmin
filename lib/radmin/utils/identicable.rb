require 'active_support/concern'

module Radmin
  module Utils
    module Identicable
      def identify_entry(store, obj_name, rel_names)
        return unless store.present?

        if store.respond_to?(:has_key?)
          arg_oriented = store[obj_name]

          if arg_oriented.present?
            if rel_names.blank?
              arg_oriented
            else
              return unless arg_oriented.respond_to?(:has_key?)

              rel_key = rel_names.find { |k| arg_oriented.has_key?(k) }
              arg_oriented[rel_key]
            end
          else
            store[nil].presence
          end
        else
          store
        end
      end
    end
  end
end