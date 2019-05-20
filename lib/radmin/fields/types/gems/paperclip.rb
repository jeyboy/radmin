require 'radmin/fields/types/file_upload'

module Radmin
  module Fields
    module Types
      module Gems
        class Paperclip < Radmin::Fields::Types::FileUpload
          Radmin::Fields::Types.register(self)

          # register_property :delete_method do
          #   "delete_#{name}" if bindings[:object].respond_to?("delete_#{name}")
          # end
          #
          # register_property :thumb_method do
          #   @styles ||= bindings[:object].send(name).styles.collect(&:first)
          #   @thumb_method ||= @styles.detect { |s| [:thumb, 'thumb', :thumbnail, 'thumbnail'].include?(s) } || @styles.first || :original
          # end
          #
          # def resource_url(thumb = false)
          #   value.try(:url, (thumb || :original))
          # end
        end
      end
    end
  end
end
