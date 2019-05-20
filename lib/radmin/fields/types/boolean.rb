module Radmin
  module Fields
    module Types
      class Boolean < Radmin::Fields::Base
        Radmin::Fields::Types.register(self)

        register_property :partial do
          :form_boolean
        end

        # register_property :view_helper do
        #   :check_box
        # end
        #
        # register_property :pretty_value do
        #   case value
        #   when nil
        #     %(<span class='label label-default'>&#x2012;</span>)
        #   when false
        #     %(<span class='label label-danger'>&#x2718;</span>)
        #   when true
        #     %(<span class='label label-success'>&#x2713;</span>)
        #   end.html_safe
        # end
        #
        # register_property :export_value do
        #   value.inspect
        # end

        # # Accessor for field's help text displayed below input field.
        # def generic_help
        #   ''
        # end
      end
    end
  end
end
