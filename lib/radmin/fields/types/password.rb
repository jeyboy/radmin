require 'radmin/fields/types/string'

module Radmin
  module Fields
    module Types
      class Password < Radmin::Fields::Types::String
        Radmin::Fields::Types.register(self)

        register_property :view_helper do
          :password_field
        end

        # register_property :formatted_value do
        #   ''.html_safe
        # end
        #
        # register_property :visible do
        #   section.is_a?(Radmin::Sections::Edit)
        # end
        #
        # register_property :pretty_value do
        #   '*****'
        # end
        #
        # def parse_input(params)
        #   params[name] = params[name].presence
        # end
        #        #
        # # Password field's value does not need to be read
        # def value
        #   ''
        # end
      end
    end
  end
end
