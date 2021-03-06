require 'radmin/fields/base'
# require 'rails_admin/support/datetime'

module Radmin
  module Fields
    module Types
      class Datetime < Radmin::Fields::Base
        Radmin::Fields::Types.register(self)

        register_property :partial do
          :form_datetime
        end

        # def parser
        #   RailsAdmin::Support::Datetime.new(strftime_format)
        # end
        #
        # def parse_value(value)
        #   parser.parse_string(value)
        # end
        #
        # def parse_input(params)
        #   params[name] = parse_value(params[name]) if params[name]
        # end
        #
        # def value
        #   parent_value = super
        #   if %w(DateTime Date Time).include?(parent_value.class.name)
        #     parent_value.in_time_zone
        #   else
        #     parent_value
        #   end
        # end
        #
        # register_property :date_format do
        #   :long
        # end
        #
        # register_property :i18n_scope do
        #   [:time, :formats]
        # end
        #
        # register_property :strftime_format do
        #   begin
        #     ::I18n.t(date_format, scope: i18n_scope, raise: true)
        #   rescue ::I18n::ArgumentError
        #     "%B %d, %Y %H:%M"
        #   end
        # end

        register_property :datepicker_options do
          {
            # showTodayButton: true,
            # format: parser.to_momentjs,
          }
        end

        # register_property :html_attributes do
        #   {
        #     required: required,
        #     size: 22,
        #   }
        # end
        #
        # register_property :sort_reverse? do
        #   true
        # end
        #
        # register_property :formatted_value do
        #   if time = (value || default_value)
        #     ::I18n.l(time, format: strftime_format)
        #   else
        #     ''.html_safe
        #   end
        # end
      end
    end
  end
end
