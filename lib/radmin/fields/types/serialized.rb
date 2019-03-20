require 'radmin/fields/types/text'

module RailsAdmin
  module Fields
    module Types
      class Serialized < Radmin::Fields::Types::Text
        Radmin::Fields::Types.register(self)

        # register_instance_option :formatted_value do
        #   RailsAdmin.yaml_dump(value) unless value.nil?
        # end
        #
        # def parse_value(value)
        #   value.present? ? (RailsAdmin.yaml_load(value) || nil) : nil
        # end
        #
        # def parse_input(params)
        #   params[name] = parse_value(params[name]) if params[name].is_a?(::String)
        # end
      end
    end
  end
end
