require 'radmin/utils/configurable'

module Radmin
  module Groups
    class Base
      include Radmin::Utils::Configurable

      # Configurable group label which by default is group's name humanized.
      register_property :label do
        # (@label ||= {})[::I18n.locale] ||= (parent.fields.detect { |f| f.name == name }.try(:label) || name.to_s.humanize)
      end

      # Configurable group label which by default is group's name humanized.
      register_property :label_icon do
        nil
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