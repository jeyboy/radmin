require 'radmin/fields/base'

module Radmin
  module Fields
    module Types
      class Decimal < Radmin::Fields::Base
        Radmin::Fields::Types.register(self)
      end
    end
  end
end
