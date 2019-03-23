require 'radmin/config'
require 'radmin/sections'
require 'radmin/utils/base'
require 'radmin/models/interface'

module Radmin
  module Models
    class Base < Radmin::Models::Interface
      include Radmin::Utils::Base
      include Radmin::Sections

      # def config
      #   Radmin::Config.model self
      # end

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

      def to_param
        @to_param ||= class_name_to_path_name(@model_name) #@model_name.gsub('::', '~').underscore
      end

      def param_key
        @param_key ||= class_name_to_param_name(@model_name) #@model_name.gsub('::', '_').underscore
      end

      def pretty_name
        model.model_name.human
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

        # scope = query_scope(scope, options[:query]) if options[:query]
        # scope = filter_scope(scope, options[:filters]) if options[:filters]

        if options[:page] && options[:per]
          scope = scope.send(Kaminari.config.page_method_name, options[:page]).per(options[:per])
        end

        scope = scope.reorder("#{options[:sort]} #{options[:sort_reverse] ? 'asc' : 'desc'}") if options[:sort]

        scope
      end
    end
  end
end