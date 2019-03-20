require 'radmin/fields/base'

module Radmin
  module Fields
    module Types
      class Integer < Radmin::Fields::Base
        Radmin::Fields::Types.register(self)

        # register_property :view_helper do
        #   :number_field
        # end

        # register_instance_option :sort_reverse? do
        #   serial?
        # end
      end
    end
  end
end
