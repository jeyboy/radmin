require 'radmin/config'
require 'radmin/utils/configurable'
require 'radmin/sections'

module Radmin
  module Models
    class Base
      include Radmin::Utils::Configurable
      include Radmin::Sections

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

      def to_s
        model.to_s
      end

      def config
        Radmin::Config.model self
      end

      def to_param
        @to_param ||= @model_name.gsub('::', '~').underscore
      end

      def param_key
        @param_key ||= @model_name.gsub('::', '_').underscore
      end

      def pretty_name
        model.model_name.human
      end

      register_property :navigation_label do
        # @navigation_label ||= begin
        #   if (parent_module = abstract_model.model.parent) != Object
        #     parent_module.to_s
        #   end
        # end
      end

      register_property :navigation_icon do
        nil
      end
    end
  end
end