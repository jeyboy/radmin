require 'radmin/fields/types/text'

module Radmin
  module Fields
    module Types
      module Editors
        class CodeMirror < Radmin::Fields::Types::Text
          Radmin::Fields::Types.register(self)

          register_property :partial do
            :form_code_mirror
          end

          # # Pass the theme and mode for Codemirror
          # register_property :config do
          #   {
          #     mode: 'css',
          #     theme: 'night',
          #   }
          # end
          #
          # # Pass the location of the theme and mode for Codemirror
          # register_property :assets do
          #   {
          #     mode: '/assets/codemirror/modes/css.js',
          #     theme: '/assets/codemirror/themes/night.css',
          #   }
          # end
          #
          # # Use this if you want to point to a cloud instances of CodeMirror
          # register_property :js_location do
          #   '/assets/codemirror.js'
          # end
          #
          # # Use this if you want to point to a cloud instances of CodeMirror
          # register_property :css_location do
          #   '/assets/codemirror.css'
          # end
        end
      end
    end
  end
end
