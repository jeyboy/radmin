require 'radmin/fields/base'

module Radmin
  module Fields
    module Types
      class Text < Radmin::Fields::Base
        Radmin::Fields::Types.register(self)

        # register_instance_option :html_attributes do
        #   {
        #     required: required?,
        #     cols: '48',
        #     rows: '3',
        #   }
        # end
        #
        # register_instance_option :partial do
        #   :form_text
        # end
      end
    end
  end
end
