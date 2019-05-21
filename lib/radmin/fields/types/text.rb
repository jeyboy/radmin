require 'radmin/fields/base'

module Radmin
  module Fields
    module Types
      class Text < Radmin::Fields::Base
        Radmin::Fields::Types.register(self)

        register_property :partial do
          :form_text
        end

        # register_property :html_attributes do
        #   {
        #     required: required,
        #     cols: '48',
        #     rows: '3',
        #   }
        # end
      end
    end
  end
end
