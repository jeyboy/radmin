require 'radmin/utils/configurable'

module Radmin
  module Fields
    class Base
      include Radmin::Utils::Configurable

      def initialize(parent, name) #, properties)
        @parent = parent
        # @root = parent.root
        #
        # @abstract_model = parent.abstract_model
        # @defined = false
        @name = name.to_sym
        # @order = 0
        # @properties = properties
        # @section = parent
      end

      # Configurable group
      register_property :group do
        nil
      end


      register_instance_option :export_value do
        value.inspect
      end


      register_instance_option :view_helper do
        nil
        # :check_box
      end

      register_instance_option :render do
        nil
        # bindings[:view].render partial: "rails_admin/main/#{partial}", locals: {field: self, form: bindings[:form]}
      end

      register_instance_option :partial do
        nil
        # nested_form ? :form_nested_one : :form_filtering_select
      end


      register_instance_option :enum do
        nil
        # abstract_model.model.defined_enums[name.to_s]
      end


      # Accessor for field's help text displayed below input field.
      register_instance_option :help do
        (@help ||= {})[::I18n.locale] ||= generic_field_help
      end

      register_instance_option :hint do
        (@hint ||= '')
      end

      register_instance_option :html_attributes do
        {
            required: required?,
        }
      end

      register_instance_option :css_class do
        "#{self.name}_field"
      end

      register_instance_option :default_value do
        nil
      end

      register_instance_option :formatted_value do
        nil
        # (o = value) && o.send(associated_model_config.object_label_method)
        # bindings[:object].send(name).presence || ' - '
      end

      register_instance_option :pretty_value do
        formatted_value || ' - '
      end

      register_instance_option :multiple? do
        false
      end

      register_instance_option :queryable do
        false
      end

      register_instance_option :sortable do
        false
        # @sortable ||= abstract_model.adapter_supports_joins? && associated_model_config.abstract_model.properties.collect(&:name).include?(associated_model_config.object_label_method) ? associated_model_config.object_label_method : {abstract_model.table_name => method_name}
      end

      # serials and dates are reversed in list, which is more natural (last modified items first).
      register_instance_option :sort_reverse? do
        false
      end

      register_instance_option :searchable do
        false
        # @searchable ||= associated_model_config.abstract_model.properties.collect(&:name).include?(associated_model_config.object_label_method) ? [associated_model_config.object_label_method, {abstract_model.model => method_name}] : {abstract_model.model => method_name}
      end

      register_instance_option :search_operator do
        @search_operator ||= Radmin::Config.default_search_operator
      end

      # register_instance_option :searchable_columns do
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
      register_instance_option :required? do
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

      register_instance_option :read_only? do
        false
        # !editable?
      end

      # init status in the view
      register_instance_option :active? do
        false
      end

      register_instance_option :visible? do
        # returned = true
        # (RailsAdmin.config.default_hidden_fields || {}).each do |section, fields|
        #   next unless self.section.is_a?("RailsAdmin::Config::Sections::#{section.to_s.camelize}".constantize)
        #   returned = false if fields.include?(name)
        # end
        # returned
      end






      # Reader for nested attributes
      register_instance_option :nested_form do
        false
      end

      # # Allowed methods for the field in forms
      # register_instance_option :allowed_methods do
      #   [method_name]
      # end

      register_instance_option :inline_add do
        false
      end

      register_instance_option :inline_edit do
        false
      end

      register_instance_option :eager_load? do
        false
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