require 'radmin/fields/base'

module Radmin
  module Fields
    module Types
      class Hidden < Radmin::Fields::Base
        Radmin::Fields::Types.register(self)

        register_property :view_helper do
          :hidden_field
        end

        # register_property :label do
        #   false
        # end
        #
        # register_property :help do
        #   false
        # end
        #
        # def generic_help
        #   false
        # end
      end
    end
  end
end
