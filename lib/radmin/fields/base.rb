require 'radmin/utils/configurable'
require 'radmin/utils/bindable'
# require 'radmin/utils/groupable'

module Radmin
  module Fields
    class Base
      include Radmin::Utils::Configurable

      attr_reader :abstract_model, :name

      def initialize(section, name)
        @section = section
        # @root = parent.root
        #
        @abstract_model = section.abstract_model
        # @defined = false
        @name = name.to_sym
        # @order = 0
        @properties = abstract_model.properties
      end

      # Configurable group
      register_property :group do
        Radmin::Utils::Groupable::DEFAULT_GROUP
      end


      register_property :export_value do
        value.inspect
      end


      register_property :view_helper do
        :string
      end

      register_property :render do
        bindings[:view].
          render partial: "radmin/main/#{partial}", locals: {field: self, form: bindings[:form]}
      end

      register_property :partial do
        nil
        # nested_form ? :form_nested_one : :form_filtering_select
      end

      register_property :label do
        'label'
        # label = ((@label ||= {})[::I18n.locale] ||= abstract_model.model.human_attribute_name name)
        # label = 'Id' if label == ''
        # label
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
            required: required?,
        }
      end

      register_property :css_class do
        "#{self.name}_field"
      end

      register_property :default_value do
        nil
      end

      register_property :formatted_value do
        nil
        # (o = value) && o.send(associated_model_config.object_label_method)
        # bindings[:object].send(name).presence || ' - '
      end

      register_property :pretty_value do
        formatted_value || ' - '
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

      register_property :sortable do
        false
        # @sortable ||= abstract_model.adapter_supports_joins? && associated_model_config.abstract_model.properties.collect(&:name).include?(associated_model_config.object_label_method) ? associated_model_config.object_label_method : {abstract_model.table_name => method_name}
      end

      # serials and dates are reversed in list, which is more natural (last modified items first).
      register_property :sort_reverse do
        false
      end

      register_property :searchable do
        false
        # @searchable ||= associated_model_config.abstract_model.properties.collect(&:name).include?(associated_model_config.object_label_method) ? [associated_model_config.object_label_method, {abstract_model.model => method_name}] : {abstract_model.model => method_name}
      end

      register_property :search_operator do
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
      #
      # @see RailsAdmin::AbstractModel.properties
      register_property :required do
        false

        # context = begin
        #   if bindings && bindings[:object]
        #     bindings[:object].persisted? ? :update : :create
        #   else
        #     :nil
        #   end
        # end
        # (@required ||= {})[context] ||= !!([name] + children_fields).uniq.detect do |column_name|
        #   abstract_model.model.validators_on(column_name).detect do |v|
        #     !(v.options[:allow_nil] || v.options[:allow_blank]) &&
        #         [:presence, :numericality, :attachment_presence].include?(v.kind) &&
        #         (v.options[:on] == context || v.options[:on].blank?) &&
        #         (v.options[:if].blank? && v.options[:unless].blank?)
        #   end
        # end
      end

      register_property :read_only do
        false
        # !editable?
      end

      # init status in the view
      register_property :active do
        false
      end

      register_property :visible do
        predefined_hiddens = (Radmin::Config.default_hidden_fields || {})
        predefined_hiddens = predefined_hiddens[@section.key]

        return true unless predefined_hiddens

        predefined_hiddens.include?(name)

        # returned = true
        # (RailsAdmin.config.default_hidden_fields || {}).each do |section, fields|
        #   next unless self.section.is_a?("RailsAdmin::Config::Sections::#{section.to_s.camelize}".constantize)
        #   returned = false if fields.include?(name)
        # end
        # returned
      end






      # Reader for nested attributes
      register_property :nested_form do
        false
      end

      # # Allowed methods for the field in forms
      # register_property :allowed_methods do
      #   [method_name]
      # end

      register_property :inline_add do
        false
      end

      register_property :inline_edit do
        false
      end

      register_property :eager_load do
        false
      end


      def bindings
        @section.bindings
      end

      def with_bindings(args)
        @section.with_bindings(args)
        self
      end

      def type
        :unknown
      end

      # Reader for field's value
      def value
        bindings[:object].safe_send(name)
      rescue NoMethodError => e
        raise e.exception <<-EOM.gsub(/^\s{10}/, '')
          #{e.message}
          If you want to use a RailsAdmin virtual field(= a field without corresponding instance method),
          you should declare 'formatted_value' in the field definition.
            field :#{name} do
              formatted_value{ bindings[:object].call_some_method }
            end
        EOM
      end


      # def form_default_value
      #   (default_value if bindings[:object].new_record? && value.nil?)
      # end
      #
      # def form_value
      #   form_default_value.nil? ? formatted_value : form_default_value
      # end


      def generic_help
        # (required? ? I18n.translate('admin.form.required') : I18n.translate('admin.form.optional')) + '. '
      end

      def generic_field_help
        # model = abstract_model.model_name.underscore
        # model_lookup = "admin.help.#{model}.#{name}".to_sym
        # translated = I18n.translate(model_lookup, help: generic_help, default: [generic_help])
        # (translated.is_a?(Hash) ? translated.to_a.first[1] : translated).html_safe
      end
    end
  end
end