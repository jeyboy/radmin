require 'radmin/models/base'

module Radmin
  module Models
    @@models = {}

    def self.get_model(key, entity)
      @@models[key] ||= Radmin::Models::Base.new(entity)
    end
  end
end