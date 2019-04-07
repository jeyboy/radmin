require 'radmin/utils/configurable'
require 'radmin/utils/bindable'

module Radmin
  module Models
    class Interface
      include Radmin::Utils::Configurable
      include Radmin::Utils::Bindable

      attr_reader :model_name

      #default scope for model
      register_property :scoped do
        model
      end

      register_property :description do
        nil
      end

      register_property :weight do
        0
      end

      register_property :visible? do
        true
      end

      # parent node in navigation/breadcrumb
      register_property :parent do
        @parent_model ||= begin
          klass = model.superclass
          klass = nil if Radmin::Config.model_class_blockers[klass.to_s]
          klass
        end
      end

      register_property :pretty_name do
        model.respond_to?(:model_name) ?
          model.model_name.human :
          model_name.humanize
      end

      register_property :label do
        (@label ||= {})[::I18n.locale] ||= pretty_name
      end

      register_property :label_plural do
        (@label_plural ||= {})[::I18n.locale] ||=
          model.model_name.human(count: Float::INFINITY, default: label.pluralize(::I18n.locale))
      end

      register_property :table_name do
        @table_name ||=
          model.respond_to?(:table_name) ?
            model.table_name :
              @model_name.underscore
      end

      register_property :object_label_method do
        :to_s
      end

      register_property :navigation_label do
        @navigation_label ||= begin
          if (parent_module = model.parent) != Object
            parent_module.to_s
          end
        end
      end

      register_property :navigation_icon do
        nil
      end





      def initialize(model_or_model_name)
        @model = model_or_model_name if model_or_model_name.is_a?(Class)
        @model_name = model_or_model_name.to_s

        # ancestors = model.ancestors.collect(&:to_s)
        # if ancestors.include?('ActiveRecord::Base') && !model.abstract_class?
        #   initialize_active_record
        # elsif ancestors.include?('Mongoid::Document')
        #   initialize_mongoid
        # end
      end

      def model
        @model ||= @model_name.constantize
      end

      def to_param
        @to_param ||= class_name_to_path_name(@model_name) #@model_name.gsub('::', '~').underscore
      end

      def param_key
        @param_key ||= class_name_to_param_name(@model_name) #@model_name.gsub('::', '_').underscore
      end

      def primary_key
        raise 'Override me'
      end

      def pluralize(count)
        count == 1 ? label : label_plural
      end

      def find(id)
        raise 'Override me'
      end

      def where(*conditions)
        raise 'Override me'
      end

      def first(options = {}, scope = nil)
        all(options, scope).first
      end

      def all(options = {}, scope = nil)
        raise 'Override me'
      end

      def count(options = {}, scope = nil)
        all(options.merge(limit: false, page: false), scope).count(:all)
      end

      def destroy(objects)
        Array.wrap(objects).each(&:destroy)
      end

      def to_s
        model.to_s
      end

      # def query_scope(scope, query, fields = config.list.fields.select(&:queryable?))
      #   wb = WhereBuilder.new(scope)
      #   fields.each do |field|
      #     value = parse_field_value(field, query)
      #     wb.add(field, value, field.search_operator)
      #   end
      #   # OR all query statements
      #   wb.build
      # end
      #
      # def filter_scope(scope, filters, fields = config.list.fields.select(&:filterable?))
      #   filters.each_pair do |field_name, filters_dump|
      #     filters_dump.each do |_, filter_dump|
      #       wb = WhereBuilder.new(scope)
      #       field = fields.detect { |f| f.name.to_s == field_name }
      #       value = parse_field_value(field, filter_dump[:v])
      #
      #       wb.add(field, value, (filter_dump[:o] || 'default'))
      #       # AND current filter statements to other filter statements
      #       scope = wb.build
      #     end
      #   end
      #   scope
      # end
    end
  end
end