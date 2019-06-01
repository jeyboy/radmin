require 'radmin/config'
require 'radmin/fields/base'

module Radmin
  module Fields
    class Association < Radmin::Fields::Base
      def self.inherited(klass)
        super(klass)
      end

      register_property :partial do
        nested_form ? :form_nested_one : :form_filtering_select
      end

      # register_property :pretty_value do
      #   v = bindings[:view]
      #   [value].flatten.select(&:present?).collect do |associated|
      #     amc = polymorphic? ? RailsAdmin.config(associated) : associated_model_config # perf optimization for non-polymorphic associations
      #     am = amc.abstract_model
      #     wording = associated.send(amc.object_label_method)
      #     can_see = !am.embedded? && (show_action = v.action(:show, am, associated))
      #     can_see ? v.link_to(wording, v.url_for(action: show_action.action_name, model_name: am.to_param, id: associated.id), class: 'pjax') : ERB::Util.html_escape(wording)
      #   end.to_sentence.html_safe
      # end

      # Accessor whether association is visible or not. By default
      # association checks whether the child model is excluded in
      # configuration or not.
      register_property :visible? do
        !associated_abstract_model&.excluded?
      end

      # # use the association name as a key, not the association key anymore!
      # register_property :label do
      #   (@label ||= {})[::I18n.locale] ||= abstract_model.model.human_attribute_name association.name
      # end

      # # scope for possible associable records
      # register_property :associated_collection_scope do
      #   # bindings[:object] & bindings[:controller] available
      #   associated_collection_scope_limit = (associated_collection_cache_all ? nil : 30)
      #   proc do |scope|
      #     scope.limit(associated_collection_scope_limit)
      #   end
      # end

      # # inverse relationship
      # register_property :inverse_of do
      #   association.inverse_of
      # end

      # # preload entire associated collection (per associated_collection_scope) on load
      # # Be sure to set limit in associated_collection_scope if set is large
      # register_property :associated_collection_cache_all do
      #   @associated_collection_cache_all ||= (associated_model_config.abstract_model.count < associated_model_limit)
      # end

      # determines whether association's elements can be removed
      register_property :removable? do
        false
        # association.foreign_key_nullable?
      end

      # register_property :eager_load? do
      #   !!searchable
      # end

      # # Reader for nested attributes
      # register_property :nested_form do
      #   association.nested_options
      # end



      # # Reader for the association information hash
      # def association
      #   @properties
      # end

      # Reader for the association's child model's configuration
      def associated_abstract_model
        @associated_abstract_model || begin
          if polymorphic?
            i = 0
            return Radmin.config(properties[:klass])
          else
            @associated_abstract_model = Radmin.config(properties[:klass])
          end
        end
      end

      # Reader for the association's child model's configuration
      def associated_klass_name
        @associated_klass_name ||=
          associated_abstract_model.to_s
      end

      def associated_label_name
        instance_label_method.presence || associated_abstract_model.object_label_method
      end

      # # Reader for the association's child model object's label method
      # def associated_object_label_method
      #   @associated_object_label_method ||= associated_model_config.object_label_method
      # end
      #
      # # Reader for associated primary key
      # def associated_primary_key
      #   @associated_primary_key ||= association.primary_key
      # end

      # Reader whether this is a polymorphic association
      def polymorphic?
        properties[:is_polymorphic]
      end

      # Reader for the association's value unformatted
      def value
        obj = bindings[:object].send(properties[:name])
        inst_mtd = instance_label_method

        @label_resolver.call(inst_mtd, obj)
      end

      # # has many?
      # def multiple?
      #   true
      # end
      #
      # def virtual?
      #   true
      # end
      #
      # def associated_model_limit
      #   RailsAdmin.config.default_associated_collection_limit
      # end

      def is_association?
        true
      end

      def label_hash_caller(label, obj)
        mtd = label[properties[:name]].presence || label[name].presence || label[associated_klass_name]

        @label_resolver = method(:label_caller)

        begin
          @label_resolver.call((@instance_label_method = mtd), obj)
        rescue
          @instance_label_method = :to_s
        end
      end

      def label_proc_caller(label, obj)
        label.call(obj, name, associated_klass_name, section.key, self)
      end
    end
  end
end
