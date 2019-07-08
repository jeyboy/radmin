require 'radmin/fields/types/text'

module Radmin
  module Fields
    module Types
      class JsonList < Radmin::Fields::Types::Json
        Radmin::Fields::Types.register(self)

        register_property :pretty_value do
          res =
            value&.map do |(k, v)|
              bindings[:view].content_tag(:dl) {
                bindings[:view].content_tag(:dt, k) +
                  bindings[:view].content_tag(:dd, v)
              }
            end

          res.join.html_safe if res
        end
      end
    end
  end
end
