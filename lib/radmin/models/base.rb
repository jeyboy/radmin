require 'radmin/config'
require 'radmin/utils/base'
require 'radmin/models/interface'

module Radmin
  module Models
    class Base < Radmin::Models::Interface
      include Radmin::Utils::Base

      def properties
        {}
      end

      def virtual?
        @virtual ||= !model.respond_to?(:columns_hash)
      end

      def columns_info
        @column_types ||= begin
          if virtual?
            {}
          else
            model.columns_hash
          end
        end
      end

      def primary_key
        model.primary_key
      end

      def scoped
        where('1=1')
      end

      def find(id)
        model.find_by(primary_key => id)
      end

      def where(*conditions)
        model.where(conditions)
      end

      def all(options = {}, scope = nil)
        scope ||= scoped

        scope = scope.includes(options[:include]) if options[:include]
        scope = scope.limit(options[:limit]) if options[:limit]
        scope = scope.where(primary_key => options[:bulk_ids]) if options[:bulk_ids]

        scope = query_scope(scope, options[:query]) if options[:query]
        scope = filter_scope(scope, options[:filters]) if options[:filters]

        scope = scope.send(Kaminari.config.page_method_name, options[:page]).per(options[:per]) if options[:page] && options[:per]

        scope = scope.reorder("#{options[:sort]} #{options[:sort_reverse] ? 'asc' : 'desc'}") if options[:sort]

        scope
      end

      def query_scope(scope, query, fields = list.fields.select(&:queryable?))
      #   wb = WhereBuilder.new(scope)
      #   fields.each do |field|
      #     value = parse_field_value(field, query)
      #     wb.add(field, value, field.search_operator)
      #   end
      #   # OR all query statements
      #   wb.build
      
        scope
      end
      
      def filter_scope(scope, filters) # , fields = list.fields.select(&:filterable?)
        filters.each_pair do |field_name, filters_dump|
      #     filters_dump.each do |_, filter_dump|
      #       wb = WhereBuilder.new(scope)
      #       field = fields.detect { |f| f.name.to_s == field_name }
      #       value = parse_field_value(field, filter_dump[:v])
      #
      #       wb.add(field, value, (filter_dump[:o] || 'default'))
      #       # AND current filter statements to other filter statements
      #       scope = wb.build
      #     end
        end
      
        scope
      end
    end
  end
end