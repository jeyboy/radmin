require 'radmin/fields/types/text'

module Radmin
  module Fields
    module Types
      module Editors
        class CodeMirror < Radmin::Fields::Types::Text
          Radmin::Fields::Types.register(self)

          # # Pass the theme and mode for Codemirror
          # register_instance_option :config do
          #   {
          #     mode: 'css',
          #     theme: 'night',
          #   }
          # end
          #
          # # Pass the location of the theme and mode for Codemirror
          # register_instance_option :assets do
          #   {
          #     mode: '/assets/codemirror/modes/css.js',
          #     theme: '/assets/codemirror/themes/night.css',
          #   }
          # end
          #
          # # Use this if you want to point to a cloud instances of CodeMirror
          # register_instance_option :js_location do
          #   '/assets/codemirror.js'
          # end
          #
          # # Use this if you want to point to a cloud instances of CodeMirror
          # register_instance_option :css_location do
          #   '/assets/codemirror.css'
          # end
          #
          # register_instance_option :partial do
          #   :form_code_mirror
          # end
        end
      end
    end
  end
end
