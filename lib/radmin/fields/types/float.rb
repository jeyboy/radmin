require 'radmin/fields/base'

module Radmin
  module Fields
    module Types
      class Float < Radmin::Fields::Base
        Radmin::Fields::Types.register(self)

        register_property :default_value do
          0
        end
      end
    end
  end
end
