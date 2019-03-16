module Radmin
  class Base
    def self.radmin(&block)
      Radmin.config(self, &block)
    end
  end
end