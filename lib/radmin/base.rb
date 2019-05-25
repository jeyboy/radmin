require 'radmin/config'
require 'active_support/concern'

module Radmin
  module Base
    extend ActiveSupport::Concern

    included do |base|
      base.extend Radmin::Base

      Radmin::Models::init_class_polymorphics(base)
    end

    def radmin(&block)
      Radmin.config(self, &block)
    end

    def radmin_default_object_label_method
      new_record? ? "new #{self.class}" : "#{self.class} ##{id}"
    end

    def safe_send(value)
      # if has_attribute?(value)
      #   read_attribute(value)
      # else
      send(value)
      # end
    end

    class_methods do

    end

    module_function :radmin
  end
end