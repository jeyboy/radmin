require 'radmin/fields/types/string'

module Radmin
  module Fields
    module Types
      class BsonObjectId < Radmin::Fields::Types::String
        Radmin::Fields::Types.register(self)

        # register_property :label do
        #   label = ((@label ||= {})[::I18n.locale] ||= abstract_model.model.human_attribute_name name)
        #   label = 'Id' if label == ''
        #   label
        # end
        #
        # def generic_help
        #   'BSON::ObjectId'
        # end
        #
        # register_property :read_only do
        #   true
        # end
        #
        # register_property :sort_reverse? do
        #   serial?
        # end
        #
        # def parse_value(value)
        #   value.present? ? abstract_model.parse_object_id(value) : nil
        # end
        #
        # def parse_input(params)
        #   params[name] = parse_value(params[name]) if params[name].is_a?(::String)
        # end
      end
    end
  end
end
