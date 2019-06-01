require 'radmin/fields/association'

module Radmin
  module Fields
    module Types
      module Associations
        class HasOne < Radmin::Fields::Association
          Radmin::Fields::Types.register(self)

          register_property :formatted_value do
            (obj = value) && begin
              label_resolver.call(instance_label_method, obj)
            end
          end

          # register_property :partial do
          #   nested_form ? :form_nested_one : :form_filtering_select
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
        end
      end
    end
  end
end
