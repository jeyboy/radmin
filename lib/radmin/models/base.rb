require 'radmin/utils/base'
require 'radmin/models/interface'

module Radmin
  module Models
    class Base < Radmin::Models::Interface
      include Radmin::Utils::Base

      def model_fields
        @model_fields ||=
          (@columns_info.keys + @relation_names).uniq
      end

      def properties
        {}
      end

      # TODO: improvements?
      def virtual?
        @virtual ||= !model.respond_to?(:columns_hash)
      end

      def columns_info
        @columns_info ||= begin
          virtual? ? {} : model.columns_hash
        end
      end

      def relations_info
        @relations_info ||= begin
          @relation_names = []

          if model.respond_to?(:reflections)
            model.reflections.each_with_object({}) do |(rel_name, rel), res|
              @relation_names << rel_name unless columns_info.has_key?(rel.foreign_key.to_s)

              res[rel.foreign_key.to_s] = rel
              res[rel_name.to_s] = rel
            end
          else
            {}
          end
        end
      end

      def primary_key
        model.primary_key
      end

      def scoped
        model
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

        joiner = search_schema == :or ? ' OR ' : ' AND '
        is_or_branch = search_schema == :or
        
        fields =
          list.fields.each_with_object({}) { |(field_name, field), res|
            res[field.name.to_s] = field if field.queryable?
          }

        fields.each_pair do |name, field|
          field.searchable_attrs.each do |(mdl, mdl_scope)|
            adapter_type = self.class.adapter_type(mdl)

            next unless mdl

            mdl_filed_name = "#{mdl.table_name}.#{field_name}"

            where_params =
              filters_dump.each_with_object([[], []]) do |(_, filter_dump), res|
                cmd = filter_cmds[search_operator]

                next unless cmd

                cmd.call(res, mdl_filed_name, query, field.type, adapter_type)
              end

            scope = scope.merge(mdl_scope) if mdl_scope

            scope = scope.merge(
              begin
                rel = mdl.where(where_params.first.join(joiner), *where_params.last)
                is_or_branch ? mdl.or(rel) : rel
              end
            )
          end
        end

        scope
      end
      
      def filter_scope(scope, filters) # , fields = list.fields.select(&:filterable?)
        fields =
          list.fields.each_with_object({}) { |(field_name, field), res|
            res[field.name.to_s] = field if field.filterable?
          }

        case filter_schema
          when :or_and, :or_or, :and_and
            filter_by_schema(scope, filters, fields, filter_schema)
          else
            filter_manual(scope, filters, fields)
        end
      end

      private

      def filter_by_schema(scope, filters, fields, schema)
        filter_cmds = Radmin::Config.filter_cmds

        joiner = schema == :or_and || schema == :or_or ? ' OR ' : ' AND '
        is_or_branch = schema == :or_or

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

            scope = scope.merge(
              begin
                rel = mdl.where(where_params.first.join(joiner), *where_params.last)
                is_or_branch ? mdl.or(rel) : rel
              end
            )
          end
        end

        scope
      end

      def filter_manual(scope, filters, fields)
        filter_cmds = Radmin::Config.filter_cmds

        # filters.each_pair do |field_name, filters_dump|
        #   field = fields[field_name]
        #
        #   next unless field
        #
        #   field.filterable_attrs.each do |(mdl, mdl_scope)|
        #     adapter_type = self.class.adapter_type(mdl)
        #
        #     next unless mdl
        #
        #     mdl_filed_name = "#{mdl.table_name}.#{field_name}"
        #
        #     where_params =
        #         filters_dump.each_with_object([[], []]) do |(_, filter_dump), res|
        #           cmd = filter_cmds[filter_dump['o']]
        #
        #           next unless cmd
        #
        #           cmd.call(res, mdl_filed_name, filter_dump['v'], field.type, adapter_type)
        #         end
        #
        #     scope = scope.merge(mdl_scope) if mdl_scope
        #     scope = scope.merge(mdl.where(where_params.first.join(" OR "), *where_params.last))
        #   end
        # end

        scope
      end
    end
  end
end