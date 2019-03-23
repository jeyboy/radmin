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
        where('1=1')
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
          klass = nil if klass.to_s.in?(%w(Object BasicObject ActiveRecord::Base))
          klass
        end
      end

      register_property :label do
        (@label ||= {})[::I18n.locale] ||= model.model_name.human
      end

      register_property :label_plural do
        (@label_plural ||= {})[::I18n.locale] ||= model.model_name.human(count: Float::INFINITY, default: label.pluralize(::I18n.locale))
      end

      # def pluralize(count)
      #   count == 1 ? label : label_plural
      # end

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

      def primary_key
        raise 'Override me'
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
        scope ||= scoped

        scope = scope.includes(options[:include]) if options[:include]
        scope = scope.limit(options[:limit]) if options[:limit]
        scope = scope.where(primary_key => options[:bulk_ids]) if options[:bulk_ids]

        # scope = query_scope(scope, options[:query]) if options[:query]
        # scope = filter_scope(scope, options[:filters]) if options[:filters]

        if options[:page] && options[:per]
          scope = scope.send(Kaminari.config.page_method_name, options[:page]).per(options[:per])
        end

        scope = scope.reorder("#{options[:sort]} #{options[:sort_reverse] ? 'asc' : 'desc'}") if options[:sort]

        scope
      end

      def count(options = {}, scope = nil)
        all(options.merge(limit: false, page: false), scope).count(:all)
      end

      def destroy(objects)
        Array.wrap(objects).each(&:destroy)
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