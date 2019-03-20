require 'radmin/fields/types/text'

module Radmin
  module Fields
    module Types
      module Gems
        class SimpleMDE < Radmin::Fields::Types::Text
          Radmin::Fields::Types.register(self)

          # # If you want to have a different SimpleMDE config for each instance
          # # you can override this option with these values: https://github.com/sparksuite/simplemde-markdown-editor#configuration
          # register_instance_option :instance_config do
          #   nil
          # end
          #
          # # Use this if you want to point to a cloud instance of the base SimpleMDE
          # register_instance_option :js_location do
          #   "#{Rails.application.config.assets.prefix}/simplemde.min.js"
          # end
          #
          # register_instance_option :css_location do
          #   "#{Rails.application.config.assets.prefix}/simplemde.min.css"
          # end
          #
          # register_instance_option :partial do
          #   :form_simple_mde
          # end
        end
      end
    end
  end
end
