require 'radmin/fields/association'

module Radmin
  module Fields
    module Types
      module Associations
        class HasMany < Radmin::Fields::Association
          Radmin::Fields::Types.register(self)

          register_property :partial do
            nested_form ? :form_nested_many : :form_filtering_multiselect
          end

          # # orderable associated objects
          # register_property :orderable do
          #   false
          # end
          #
          # register_property :inline_add do
          #   true
          # end
          #
          # def name
          #   nested_form ? "#{super}_attributes".to_sym : "#{super.to_s.singularize}_ids".to_sym # name_ids
          # end
          #
          # # Reader for validation errors of the bound object
          # def errors
          #   bindings[:object].errors[name]
          # end
        end
      end
    end
  end
end
