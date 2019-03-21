require 'radmin/config'

module Radmin
  module Base
    def self.radmin(&block)
      Radmin.config(self, &block)
    end
  end
end