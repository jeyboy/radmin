# require 'rails_admin/config/fields/base'
require 'radmin/fields/types/file_upload'

module Radmin
  module Fields
    module Types
      module Gems
        class Carrierwave < Radmin::Fields::Types::FileUpload
          Radmin::Fields::Types.register(self)

          # register_property :thumb_method do
          #   @thumb_method ||= ((versions = bindings[:object].send(name).versions.keys).detect { |k| k.in?([:thumb, :thumbnail, 'thumb', 'thumbnail']) } || versions.first.to_s)
          # end
          #
          # register_property :delete_method do
          #   "remove_#{name}"
          # end
          #
          # register_property :cache_method do
          #   "#{name}_cache"
          # end
          #
          # def resource_url(thumb = false)
          #   return nil unless (uploader = bindings[:object].send(name)).present?
          #   thumb.present? ? uploader.send(thumb).url : uploader.url
          # end
        end
      end
    end
  end
end
