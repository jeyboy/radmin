require 'radmin/fields/association'

module Radmin
  module Fields
    module Types
      module Associations
        class HasOne < Radmin::Fields::Association
          Radmin::Fields::Types.register(self)

          # register_property :partial do
          #   nested_form ? :form_nested_one : :form_filtering_select
          # end
          #
          # # Accessor for field's formatted value
          # register_property :formatted_value do
          #   (o = value) && o.send(associated_model_config.object_label_method)
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
          # def editable?
          #   (nested_form || abstract_model.model.new.respond_to?("#{name}_id=")) && super
          # end
          #
          # def selected_id
          #   value.try :id
          # end
          #
          # def name
          #   nested_form ? "#{name}_attributes".to_sym : "#{name}_id".to_sym
          # end
          #
          # def multiple?
          #   false
          # end
        end
      end
    end
  end
end
