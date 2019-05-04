require 'radmin/utils/configurable'

module Radmin
  module Groups
    class Base
      include Radmin::Utils::Configurable

      attr_reader :section, :name
      
      def initialize(section, name) #, properties)
        @section = section
        @name = name.to_s
      end

      def bindings
        section.bindings
      end

      def with_bindings(args)
        section.with_bindings(args)
        self
      end

      # Configurable group label which by default is group's name humanized.
      register_property :label do
        @name
        # (@label ||= {})[::I18n.locale] ||= (parent.fields.detect { |f| f.name == name }.try(:label) || name.to_s.humanize)
      end

      # Configurable group label which by default is group's name humanized.
      register_property :label_icon do
        nil
      end

      # Should it visible by default
      register_property :visible? do
        true
      end

      # Should it open by default
      register_property :open? do
        true
      end

      # Configurable help text
      register_property :help do
        nil
      end
    end
  end
end