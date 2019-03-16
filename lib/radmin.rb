require 'radmin/engine'

require 'radmin/config'
require 'radmin/actions'

module Radmin
  def self.config(entity = nil, &block)
    if entity
      Radmin::Config.model(entity, &block)
    elsif block_given?
      block.call(Radmin::Config)
    else
      Radmin::Config
    end
  end
end
