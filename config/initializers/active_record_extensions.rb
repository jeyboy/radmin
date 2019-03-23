begin
  ActiveSupport.on_load(:active_record) do
    module ActiveRecord
      class Base
        include Radmin::Base

        # def self.radmin(&block)
        #   Radmin.config(self, &block)
        # end
        #
        # def rails_admin_default_object_label_method
        #   new_record? ? "new #{self.class}" : "#{self.class} ##{id}"
        # end
        #
        # def safe_send(value)
        #   if has_attribute?(value)
        #     read_attribute(value)
        #   else
        #     send(value)
        #   end
        # end
      end
    end

    Rails.application.eager_load!
  end
rescue
  print "Can't add default method for models"
end
