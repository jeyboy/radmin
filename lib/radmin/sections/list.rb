require 'radmin/sections/base'

module Radmin
  module Sections
    class List < Radmin::Sections::Base
      register_property :inline_menu do
        false
      end

      register_property :show_checkboxes do
        true
      end

      register_property :filters do
        []
      end

      register_property :scopes do
        []
      end

      register_property :bulkable do
        true
      end

      # Number of items listed per page
      register_property :items_per_page do
        Radmin::Config.default_items_per_page
      end

      # Positive value shows only prev, next links in pagination.
      # This is for avoiding count(*) query.
      register_property :compact_pagination do
        false
      end

      register_property :sort_by do
        abstract_model.primary_key
      end

      register_property :sort_reverse do
        true # By default show latest first
      end

      register_property :row_css_class do
        ''
      end
    end
  end
end