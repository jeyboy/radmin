require 'radmin/utils/configurable'
require 'radmin/utils/bindable'
require 'radmin/utils/scopeable'
require 'radmin/utils/identicable'
require 'radmin/sections'
require 'radmin/config'

module Radmin
  module Models
    class Interface
      include Radmin::Utils::Configurable
      include Radmin::Utils::Bindable
      include Radmin::Utils::Identicable
      include Radmin::Utils::Scopeable
      include Radmin::Sections

      attr_reader :model_name

      #default scope for model
      register_property :scoped do
        @scoped ||= begin
          scoping = identify_scope_arg(to_param)

          if scoping
            model.merge(scoping)
          end || model
        end
      end

      register_property :filter_schema do
        Radmin::Config.default_filter_schema
      end

      register_property :search_schema do
        Radmin::Config.default_search_schema
      end
      
      register_property :search_operator do
        Radmin::Config.default_search_operator
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
        (@label_plural ||= {})[::I18n.locale] ||= begin
          model.respond_to?(:model_name) ?
            model.model_name.human(count: Float::INFINITY, default: label.pluralize(::I18n.locale)) :
              label.pluralize(::I18n.locale)
        end
      end

      register_property :table_name do
        @table_name ||=
          model.respond_to?(:table_name) ?
            model.table_name :
              @model_name.underscore
      end

      register_property :object_label_method do
        mtds = Radmin::Config::label_methods

        if mtds.present?
          res =
            identify_entry(mtds[current_action], to_param, [:self]).presence ||
              identify_entry(mtds[nil], to_param, [:self]).presence

          nil if res.is_a?(Proc) #INFO We can't use here Proc at this time
        end || :to_s
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


      def self.adapter_type(mdl)
        mdl.connection.adapter_name.downcase
      end

      def self.identify_filter_params(mdl, filter)
        if filter == true
          [mdl, nil]
        elsif filter.is_a?(Array)
          # [TargetClass, -> {}]
          # [TargetClass, SecondClass.scope_name]
          # [TargetClass, :target_class_scope_name]

          case filter.last.class.name
            when 'Proc', 'ActiveRecord::Relation', 'Symbol'
              [mdl, filter.last]
            else
              raise 'Wrong filter config'
          end
        elsif filter == false
          nil
        else
          raise 'Wrong filter config'
        end
      end

      def identify_filter_params(filter)
        self.class.identify_filter_params(model, filter)
      end

      def identify_filters_params(filters)
        if filters == true
          [identify_filter_params(filters)]
        elsif filters.is_a?(Array)
          filters.map do |s|
            identify_filter_params(s)
          end
        else
          raise 'Wrong searchable config'
        end.compact
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

      def excluded?
        Radmin::Config.excluded_models.include?(@model_name)
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

      def model_fields
        []
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
      
      def query_scope(scope, query, fields = list.fields.select(&:queryable?))
        raise 'Override me'
      end

      def filter_scope(scope, filters) # , fields = list.fields.select(&:filterable?)
        raise 'Override me'
      end
    end
  end
end