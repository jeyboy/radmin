require 'radmin/fields/types/associations/has_many'

module Radmin
  module Fields
    module Types
      module Associations
        class HasAndBelongsToMany < Radmin::Fields::Types::Associations::HasMany
          Radmin::Fields::Types.register(self)
        end
      end
    end
  end
end
