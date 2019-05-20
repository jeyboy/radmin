require 'radmin/fields/base'

module Radmin
  module Fields
    module Types
      class Enum < Radmin::Fields::Base
        Radmin::Fields::Types.register(self)

        # register_property :partial do
        #   :form_enumeration
        # end
        #
        # register_property :enum_method do
        #   @enum_method ||= bindings[:object].class.respond_to?("#{name}_enum") || bindings[:object].respond_to?("#{name}_enum") ? "#{name}_enum" : name
        # end
        #
        # register_property :enum do
        #   bindings[:object].class.respond_to?(enum_method) ? bindings[:object].class.send(enum_method) : bindings[:object].send(enum_method)
        # end
        #
        # register_property :pretty_value do
        #   if enum.is_a?(::Hash)
        #     enum.reject { |_k, v| v.to_s != value.to_s }.keys.first.to_s.presence || value.presence || ' - '
        #   elsif enum.is_a?(::Array) && enum.first.is_a?(::Array)
        #     enum.detect { |e| e[1].to_s == value.to_s }.try(:first).to_s.presence || value.presence || ' - '
        #   else
        #     value.presence || ' - '
        #   end
        # end
        #
        # register_property :multiple? do
        #   properties && [:serialized].include?(properties.type)
        # end
      end
    end
  end
end
