require 'radmin/actions/base'

module Radmin
  module Actions
    class Export < Radmin::Actions::Base
      Radmin::Actions::register(self)

      register_property :collection? do
        true
      end

      register_property :bulkable? do
        true
      end

      register_property :scopeable? do
        true
      end

      register_property :http_methods do
        [:get, :post]
      end

      register_property :controller do
        proc do
          # if format = params[:json] && :json || params[:csv] && :csv || params[:xml] && :xml
          #   request.format = format
          #   @schema = HashHelper.symbolize(params[:schema].slice(:except, :include, :methods, :only).permit!.to_h) if params[:schema] # to_json and to_xml expect symbols for keys AND values.
          #   @objects = list_entries(@model_config, :export)
          #   index
          # else
          #   render current_action.template_name
          # end
        end
      end

      register_property :link_icon do
        'file-download'
      end
    end
  end
end