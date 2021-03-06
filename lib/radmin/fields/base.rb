require 'radmin/utils/configurable'
require 'radmin/utils/bindable'
require 'radmin/utils/identicable'
# require 'radmin/utils/groupable'

module Radmin
  module Fields
    class Base
      include Radmin::Utils::Configurable
      include Radmin::Utils::Identicable

      VALIDATION_REQUIRE_RULES = [:presence, :numericality, :attachment_presence].freeze

      attr_reader :abstract_model, :name, :properties, :section


      register_property :render do
        bindings[:view].render(partial: "radmin/main/#{partial}", locals: {field: self, form: bindings[:form]})
      end

      register_property :partial do
        :form_field
      end

      register_property :view_helper do
        :text_field
      end

      # Output like raw value
      register_property :is_raw do
        false
      end


      # Configurable group
      register_property :group do
        Radmin::Utils::Groupable::DEFAULT_GROUP
      end

      register_property :label do
        abstract_model.model.human_attribute_name(name).presence || 'Id'

        # label = ((@label ||= {})[::I18n.locale] ||= abstract_model.model.human_attribute_name name)
        # label = 'Id' if label == ''
        # label
      end

      register_property :instance_label_method do
        @instance_label_method ||= begin
          res =
            if is_association? || Radmin::Config::search_label_method_for_attribute
              assoc_res = identify_label_arg(abstract_model.to_param, [properties[:name], name]) if is_association?
              assoc_res ||= identify_label_arg(name)
            end

          @label_resolver = label_arg_to_label_resover(res)

          res || (is_association? ? :to_s : name)
        end
      end

      register_property :additional_info do
        nil
      end

      register_property :enum do
        nil
        # abstract_model.model.defined_enums[name.to_s]
      end

      # Accessor for field's help text displayed below input field.
      register_property :help do
        (@help ||= {})[::I18n.locale] ||= generic_field_help
      end

      register_property :hint do
        (@hint ||= '')
      end

      register_property :html_attributes do
        {
          required: required,
        }
      end

      register_property :type_css_class do
        "#{type}_type"
      end

      register_property :css_class do
        "#{self.name}_field"
      end



      register_property :default_value do
        nil
      end

      register_property :formatted_value do
        value

        # bindings[:object].send(name).presence || ' - '
      end

      register_property :pretty_value do
        formatted_value || ' - '
      end

      register_property :export_value do
        value.inspect
      end


      register_property :errors do
        bindings[:object].errors[name] if bindings[:object]
      end

      register_property :multiple do
        false
      end

      register_property :queryable do
        false
      end

      register_property :filterable do
        false
      end

      register_property :filterable_enum do
        nil
      end

      register_property :sortable do
        false
        # @sortable ||= abstract_model.adapter_supports_joins? && associated_model_config.abstract_model.properties.collect(&:name).include?(associated_model_config.object_label_method) ? associated_model_config.object_label_method : {abstract_model.table_name => name}
      end

      # serials and dates are reversed in list, which is more natural (last modified items first).
      register_property :sort_reverse do
        false
      end

      register_property :searchable do
        false
        # @searchable ||= associated_model_config.abstract_model.properties.collect(&:name).include?(associated_model_config.object_label_method) ? [associated_model_config.object_label_method, {abstract_model.model => name}] : {abstract_model.model => name}
      end

      register_property :searchable_operator do
        @search_operator ||= Radmin::Config.default_search_operator
      end

      # register_property :searchable_columns do
      #   @searchable_columns ||= begin
      #     case searchable
      #       when true
      #         [{column: "#{abstract_model.table_name}.#{name}", type: type}]
      #       when false
      #         []
      #       when :all # valid only for associations
      #         table_name = associated_model_config.abstract_model.table_name
      #         associated_model_config.list.fields.collect { |f| {column: "#{table_name}.#{f.name}", type: f.type} }
      #       else
      #         [searchable].flatten.collect do |f|
      #           if f.is_a?(String) && f.include?('.')                            #  table_name.column
      #             table_name, column = f.split '.'
      #             type = nil
      #           elsif f.is_a?(Hash)                                              #  <Model|table_name> => <attribute|column>
      #             am = f.keys.first.is_a?(Class) && AbstractModel.new(f.keys.first)
      #             table_name = am && am.table_name || f.keys.first
      #             column = f.values.first
      #             property = am && am.properties.detect { |p| p.name == f.values.first.to_sym }
      #             type = property && property.type
      #           else                                                             #  <attribute|column>
      #             am = (association? ? associated_model_config.abstract_model : abstract_model)
      #             table_name = am.table_name
      #             column = f
      #             property = am.properties.detect { |p| p.name == f.to_sym }
      #             type = property && property.type
      #           end
      #           {column: "#{table_name}.#{column}", type: (type || :string)}
      #         end
      #     end
      #   end
      # end

      # Accessor for whether this is field is mandatory.
      register_property :required do
        context = begin
          if bindings[:object]
            bindings[:object].persisted? ? :update : :create
          else
            :nil
          end
        end

        (@required ||= {})[context] ||=
          !!
            abstract_model.model.validators_on(name).detect do |v|
              !(v.options[:allow_nil] || v.options[:allow_blank]) &&
                (v.options[:on] == context || v.options[:on].blank?) &&
                (v.options[:if].blank? && v.options[:unless].blank?) &&
                VALIDATION_REQUIRE_RULES.include?(v.kind)
            end

          # !!([name] + children_fields).uniq.detect do |column_name|
          #   abstract_model.model.validators_on(column_name).detect do |v|
          #     !(v.options[:allow_nil] || v.options[:allow_blank]) &&
          #       [:presence, :numericality, :attachment_presence].include?(v.kind) &&
          #       (v.options[:on] == context || v.options[:on].blank?) &&
          #       (v.options[:if].blank? && v.options[:unless].blank?)
          #   end
          # end
      end

      register_property :read_only do
        false
      end

      # init status in the view
      register_property :active do
        false
      end

      register_property :visible do
        is_visible?(abstract_model.to_param, [name])
      end


      # Reader for nested attributes
      register_property :nested_form do
        false
      end

      register_property :inverse_of do
        nil
      end


      register_property :children_fields do
        []
      end


      # Allowed methods for the field in forms
      register_property :allowed_methods do
        [name]
      end

      register_property :inline_add do
        false
      end

      register_property :inline_edit do
        false
      end

      register_property :eager_load do
        false
      end




      def initialize(section, name)
        @section = section
        # @root = parent.root
        #
        @abstract_model = section.abstract_model
        # @defined = false
        @name = name.to_sym
        # @order = 0
        @properties = abstract_model.properties[name] || {}
      end

      def bindings
        @section.bindings
      end

      def with_bindings(args)
        @section.with_bindings(args)
        self
      end

      def current_action
        @section.current_action
      end

      def foreign_key
        @properties[:foreign_key]
      end

      # Reader for field's type
      def type
        @type ||= self.class.name.to_s.demodulize.underscore.to_sym
      end

      # Reader for field's value
      def value
        label_resolver.call(instance_label_method, bindings[:object])
      end

      def filterable?
        filterable && filterable_attrs.present?
      end

      def filterable_attrs
        @filterable_attrs ||=
          abstract_model.identify_filters_params(filterable)
      end

      def filter_settings
        {}
      end

      def searchable?
        searchable && searchable_attrs.present?
      end

      def searchable_attrs
        @searchable_attrs ||=
          abstract_model.identify_filters_params(searchable)
      end

      def form_value
        form_default_value =
          (default_value if bindings[:object].new_record? && value.nil?)

        form_default_value.nil? ? formatted_value : form_default_value
      end


      def generic_help
        (required ? I18n.translate('admin.form.required') : I18n.translate('admin.form.optional')) + '. '
      end

      def generic_field_help
        model = abstract_model.model_name.underscore
        model_lookup = "admin.help.#{model}.#{name}".to_sym

        translated = I18n.translate(model_lookup, help: generic_help, default: [generic_help])
        (translated.is_a?(Hash) ? translated.to_a.first[1] : translated).html_safe
      end

      def is_association?
        false
      end

      def label_resolver
        @label_resolver || begin
          instance_label_method unless @instance_label_method
          @label_resolver = label_arg_to_label_resover(@instance_label_method) unless @label_resolver
        end

        @label_resolver
      end

      def is_visible?(mdl_name, field_names)
        predefined_hiddens = Radmin::Config.default_hidden_fields

        return true if predefined_hiddens.blank?

        res =
            identify_entry(predefined_hiddens[current_action], mdl_name, field_names).presence ||
                identify_entry(predefined_hiddens[nil].presence || predefined_hiddens[:nil], mdl_name, field_names).presence

        if res.is_a?(Proc)
          #INFO We can't use here Proc at this time
          raise "Can't use Proc for visibility identification: #{mdl_name}##{field_name}"
        else
          !res
        end
      end

      private

      # PROC = ->(obj, rel_class, section_name, field) {}
      #  section_name_or_nil => { field_name => { relation_field_name => Array or String or Symbol or Proc } }
      #  section_name_or_nil => { field_name => Array or String or Symbol or Proc }
      #  section_name_or_nil => Array or String or Symbol or Proc
      #  Array or String or Symbol or Proc
      def identify_label_arg(obj_name, rel_names = nil)
        mtds = Radmin::Config::label_methods

        return unless mtds.present?

        identify_entry(mtds[current_action], obj_name, rel_names).presence ||
          identify_entry(mtds[nil].presence || mtds[:nil], obj_name, rel_names).presence
      end

      def label_arg_to_label_resover(arg)
        case arg.class.to_s
          when 'Proc'
            method(:label_proc_caller)
          when 'Array'
            method(:label_array_caller)
          else
            # hash variations
            if arg.respond_to?(:has_key?)
              method(:label_hash_caller)
            else
              method(:label_caller)
            end
          end
      end

      def label_caller(label, obj)
        obj.safe_send(label)
      rescue NoMethodError => e
        raise e.exception <<-EOM.gsub(/^\s{10}/, '')
          #{e.message}
          If you want to use a Radmin virtual field(= a field without corresponding instance method),
          you should declare 'formatted_value' in the field definition.
            field :#{name} do
              formatted_value{ bindings[:object].call_some_method }
            end
        EOM
      end

      def label_array_caller(labels, obj)
        @label_resolver = method(:label_caller)
        index = 0

        begin
          obj.safe_send((@instance_label_method = labels[index]))
        rescue NoMethodError => e
          index += 1

          if index < labels.length
            retry
          else
            @instance_label_method = name
            return
          end
        end
      end

      def label_hash_caller(label, obj)
        raise 'Only relations is supported'
      end

      def label_proc_caller(label, obj)
        label.call(obj, name, nil, current_action, self)
      end
    end
  end
end