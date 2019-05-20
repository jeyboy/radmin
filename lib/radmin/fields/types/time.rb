require 'radmin/fields/types/datetime'

module Radmin
  module Fields
    module Types
      class Time < Radmin::Fields::Types::Datetime
        Radmin::Fields::Types.register(self)

        # def parse_value(value)
        #   parent_value = super(value)
        #   return unless parent_value
        #   value_with_tz = parent_value.in_time_zone
        #   ::DateTime.parse(value_with_tz.strftime('%Y-%m-%d %H:%M:%S'))
        # end
        #
        # register_property :strftime_format do
        #   '%H:%M'
        # end
      end
    end
  end
end
