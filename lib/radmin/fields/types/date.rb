require 'radmin/fields/types/datetime'

module Radmin
  module Fields
    module Types
      class Date < Radmin::Fields::Types::Datetime
        Radmin::Fields::Types.register(self)

        # register_property :date_format do
        #   :long
        # end
        #
        # register_property :i18n_scope do
        #   [:date, :formats]
        # end
        #
        # register_property :datepicker_options do
        #   {
        #     showTodayButton: true,
        #     format: parser.to_momentjs,
        #   }
        # end
        #
        # register_property :html_attributes do
        #   {
        #     required: required?,
        #     size: 18,
        #   }
        # end
      end
    end
  end
end
