require 'radmin/models/abstract'

module Radmin
  module Models
    @@models = {}

    def self.get_model(key, entity)
      @@models[key] ||=
        Radmin::Models::Abstract.new(entity)
    end
  end
end