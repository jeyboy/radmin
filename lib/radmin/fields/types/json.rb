require 'radmin/fields/types/text'

module Radmin
  module Fields
    module Types
      class Json < Radmin::Fields::Types::Text
        Radmin::Fields::Types.register(self)
        Radmin::Fields::Types.register(:jsonb, self)

        # register_property :formatted_value do
        #   value ? JSON.pretty_generate(value) : nil
        # end
        #
        # register_property :pretty_value do
        #   bindings[:view].content_tag(:pre) { formatted_value }.html_safe
        # end
        #
        # def parse_value(value)
        #   value.present? ? JSON.parse(value) : nil
        # end
        #
        # def parse_input(params)
        #   params[name] = parse_value(params[name]) if params[name].is_a?(::String)
        # end
      end
    end
  end
end
