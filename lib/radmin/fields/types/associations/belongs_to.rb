require 'radmin/fields/association'

module Radmin
  module Fields
    module Types
      module Associations
        class BelongsTo < Radmin::Fields::Association
          Radmin::Fields::Types.register(self)

          register_property :formatted_value do
            (obj = value) && begin
              label_resolver.call(instance_label_method, obj)
            end
          end

          # register_property :sortable do
          #   @sortable ||= abstract_model.adapter_supports_joins? && associated_model_config.abstract_model.properties.collect(&:name).include?(associated_model_config.object_label_method) ? associated_model_config.object_label_method : {abstract_model.table_name => name}
          # end
          #
          # register_property :searchable do
          #   @searchable ||= associated_model_config.abstract_model.properties.collect(&:name).include?(associated_model_config.object_label_method) ? [associated_model_config.object_label_method, {abstract_model.model => name}] : {abstract_model.model => name}
          # end
          #
          # register_property :inline_add do
          #   true
          # end
          #
          # register_property :inline_edit do
          #   true
          # end
          #
          # def selected_id
          #   bindings[:object].send(foreign_key)
          # end
          #
          # def name
          #   nested_form ? "#{name}_attributes".to_sym : association.foreign_key
          # end
        end
      end
    end
  end
end
