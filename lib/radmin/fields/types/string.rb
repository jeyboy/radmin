require 'radmin/fields/base'

module Radmin
  module Fields
    module Types
      class String < Radmin::Fields::Base
        Radmin::Fields::Types.register(self)

        register_property :partial do
          :form_field
        end

        # register_property :html_attributes do
        #   {
        #     required: required,
        #     maxlength: length,
        #     size: input_size,
        #   }
        # end
        #
        # def input_size
        #   [50, length.to_i].reject(&:zero?).min
        # end
        #
        # def generic_help
        #   text = (required ? I18n.translate('admin.form.required') : I18n.translate('admin.form.optional')) + '. '
        #   if valid_length.present? && valid_length[:is].present?
        #     text += "#{I18n.translate('admin.form.char_length_of').capitalize} #{valid_length[:is]}."
        #   else
        #     max_length = [length, valid_length[:maximum] || nil].compact.min
        #     min_length = [0, valid_length[:minimum] || nil].compact.max
        #     if max_length
        #       text +=
        #         if min_length == 0
        #           "#{I18n.translate('admin.form.char_length_up_to').capitalize} #{max_length}."
        #         else
        #           "#{I18n.translate('admin.form.char_length_of').capitalize} #{min_length}-#{max_length}."
        #         end
        #     end
        #   end
        #   text
        # end
      end
    end
  end
end
