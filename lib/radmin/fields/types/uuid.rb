require 'radmin/fields/types/string'

module Radmin
  module Fields
    module Types
      class Uuid < Radmin::Fields::Types::String
        Radmin::Fields::Types.register(self)
      end
    end
  end
end
