require 'radmin/fields/types/text'

module Radmin
  module Fields
    module Types
      class Wysihtml5 < Radmin::Fields::Types::Text
        Radmin::Fields::Types.register(self)

        # # If you want to have a different toolbar configuration for wysihtml5
        # # you can use a Ruby hash to configure these options:
        # # https://github.com/jhollingworth/bootstrap-wysihtml5/#advanced
        # register_instance_option :config_options do
        #   nil
        # end
        #
        # register_instance_option :css_location do
        #   ActionController::Base.helpers.asset_path('bootstrap-wysihtml5/index.css')
        # end
        #
        # register_instance_option :js_location do
        #   ActionController::Base.helpers.asset_path('bootstrap-wysihtml5/index.js')
        # end
        #
        # register_instance_option :partial do
        #   :form_wysihtml5
        # end
      end
    end
  end
end
