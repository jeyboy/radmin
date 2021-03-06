require 'radmin/fields/types/associations/belongs_to'

module Radmin
  module Fields
    module Types
      module Associations
        class Polymorphic < Radmin::Fields::Types::Associations::BelongsTo
          Radmin::Fields::Types.register(self)

          register_property :partial do
            :form_polymorphic_association
          end

          register_property :formatted_value do
            (obj = value) && begin
              label_resolver.call(instance_label_method, obj)
            end
          end

          # # Accessor whether association is visible or not. By default
          # # association checks that any of the child models are included in
          # # configuration.
          # register_property :visible? do
          #   associated_model_config.any?
          # end
          #
          # register_property :sortable do
          #   false
          # end
          #
          # register_property :searchable do
          #   false
          # end
          #
          # # TODO: not supported yet
          # register_property :associated_collection_cache_all do
          #   false
          # end
          #
          # # TODO: not supported yet
          # register_property :associated_collection_scope do
          #   nil
          # end
          #
          # register_property :allowed_methods do
          #   [children_fields]
          # end
          #
          # def associated_collection(type)
          #   return [] if type.blank?
          #   config = RailsAdmin.config(type)
          #   config.abstract_model.all.collect do |object|
          #     [object.send(config.object_label_method), object.id]
          #   end
          # end
          #
          # def associated_model_config
          #   @associated_model_config ||= association.klass.collect { |type| RailsAdmin.config(type) }.select { |config| !config.excluded? }
          # end
          #
          # def polymorphic_type_collection
          #   associated_model_config.collect do |config|
          #     [config.label, config.abstract_model.model.name]
          #   end
          # end
          #
          # def polymorphic_type_urls
          #   types = associated_model_config.collect do |config|
          #     [config.abstract_model.model.name, config.abstract_model.to_param]
          #   end
          #   ::Hash[*types.collect { |v| [v[0], bindings[:view].index_path(v[1])] }.flatten]
          # end
          #
          # # Reader for field's value
          # def value
          #   bindings[:object].send(association.name)
          # end
        end
      end
    end
  end
end
