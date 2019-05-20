require 'radmin/fields/base'

module Radmin
  module Fields
    module Types
      class Color < Radmin::Fields::Base
        Radmin::Fields::Types.register(self)

        # register_property :pretty_value do
        #   bindings[:view].content_tag :strong, (value.presence || ' - '), style: "color: #{color}"
        # end

        register_property :partial do
          :form_colorpicker
        end

        # register_property :color do
        #   if value.present?
        #     if value =~ /^[0-9a-fA-F]{3,6}$/
        #       '#' + value
        #     else
        #       value
        #     end
        #   else
        #     'white'
        #   end
        # end
        #
        # register_property :export_value do
        #   formatted_value
        # end
      end
    end
  end
end
