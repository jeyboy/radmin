require 'radmin/fields/types/text'

module Radmin
  module Fields
    module Types
      module Editors
        class CKEditor < Radmin::Fields::Types::Text
          Radmin::Fields::Types.register(self)

          # # If you want to have a different toolbar configuration for CKEditor
          # # create your own custom config.js and override this configuration
          # register_property :config_js do
          #   nil
          # end
          #
          # # Use this if you want to point to a cloud instances of CKeditor
          # register_property :location do
          #   nil
          # end
          #
          # # Use this if you want to point to a cloud instances of the base CKeditor
          # register_property :base_location do
          #   "#{Rails.application.config.assets.prefix}/ckeditor/"
          # end

          register_property :partial do
            :form_ck_editor
          end
        end
      end
    end
  end
end
