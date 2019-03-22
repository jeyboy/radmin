require 'radmin/config'
require 'active_support/concern'

module Radmin
  module Base
    extend ActiveSupport::Concern

    included do |base|
      base.extend Radmin::Base
    end

    def radmin(&block)
      Radmin.config(self, &block)
    end

    # class_methods do
    #
    # end

    module_function :radmin
  end
end