require 'radmin/fields/types/file_upload'

module Radmin
  module Fields
    module Types
      module Gems
        class Dragonfly < Radmin::Fields::Types::FileUpload
          Radmin::Fields::Types.register(self)

          # register_property :image? do
          #   false unless value
          #   if abstract_model.model.new.respond_to?("#{name}_name")
          #     bindings[:object].send("#{name}_name").to_s.split('.').last =~ /jpg|jpeg|png|gif/i
          #   else
          #     true # Dragonfly really is image oriented
          #   end
          # end
          #
          # register_property :delete_method do
          #   "remove_#{name}"
          # end
          #
          # register_property :cache_method do
          #   "retained_#{name}"
          # end
          #
          # register_property :thumb_method do
          #   '100x100>'
          # end
          #
          # def resource_url(thumb = false)
          #   return nil unless (v = value)
          #   thumb ? v.thumb(thumb).try(:url) : v.url
          # end
        end
      end
    end
  end
end
