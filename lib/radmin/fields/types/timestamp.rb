require 'radmin/fields/types/datetime'

module Radmin
  module Fields
    module Types
      class Timestamp < Radmin::Fields::Types::Datetime
        Radmin::Fields::Types.register(self)

        # @format = :long
        # @i18n_scope = [:time, :formats]
        # @js_plugin_options = {}
      end
    end
  end
end
