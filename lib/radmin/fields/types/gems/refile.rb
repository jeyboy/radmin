require 'radmin/fields/types/file_upload'

module Radmin
  module Fields
    module Types
      module Fems
        class Refile < Radmin::Fields::Types::FileUpload
          Radmin::Fields::Types.register(self)

          # register_property :thumb_method do
          #   [:limit, 100, 100]
          # end
          #
          # register_property :delete_method do
          #   "remove_#{name}"
          # end
          #
          # def resource_url(thumb = [])
          #   return nil unless value
          #   Object.const_get(:Refile).attachment_url(bindings[:object], name, *thumb)
          # end
        end
      end
    end
  end
end
