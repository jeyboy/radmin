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
        model
        # where('1=1')
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

      def query_scope(scope, query) # , fields = list.fields.select(&:queryable?)
        filter_cmds = Radmin::Config.filter_cmds

        fields =
          list.fields.each_with_object({}) { |(field_name, field), res|
            res[field.name.to_s] = field if field.queryable?
          }

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
        filter_cmds = Radmin::Config.filter_cmds
        
        fields =
          list.fields.each_with_object({}) { |(field_name, field), res|
            res[field.name.to_s] = field if field.filterable?
          }

        filters.each_pair do |field_name, filters_dump|
          field = fields[field_name]

          next unless field

          field.filterable_attrs.each do |(mdl, mdl_scope)|
            adapter_type = self.class.adapter_type(mdl)

            next unless mdl

            mdl_filed_name = "#{mdl.table_name}.#{field_name}"

            where_params =
              filters_dump.each_with_object([[], []]) do |(_, filter_dump), res|
                cmd = filter_cmds[filter_dump['o']]

                next unless cmd

                cmd.call(res, mdl_filed_name, filter_dump['v'], field.type, adapter_type)
              end

            scope = scope.merge(mdl_scope) if mdl_scope
            scope = scope.merge(mdl.where(where_params.first.join(" OR "), *where_params.last))
          end
        end
      
        scope
      end
    end
  end
end