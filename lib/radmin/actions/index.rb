require 'radmin/actions/base'

module Radmin
  module Actions
    class Index < Radmin::Actions::Base
      Radmin::Actions::register(self)

      register_property :collection? do
        true
      end

      register_property :http_methods do
        [:get, :post]
      end

      register_property :route_fragment do
        ''
      end

      register_property :controller do
        proc do
          @objects ||= list_entries

          scopes_list = current_model.list.scopes

          unless scopes_list.empty?
            param_scope = params[:scope]

            if param_scope.blank?
              unless scopes_list.first.blank?
                @objects = @objects.send(scopes_list.first)
              end
            elsif scopes_list.collect(&:to_s).include?(params[:scope])
              @objects = @objects.send(params[:scope].to_sym)
            end
          end

          # respond_to do |format|
          #   format.html do
          #     render @action.template_name, status: @status_code || :ok
          #   end
          #
          #   format.json do
          #     output = begin
          #       if params[:compact]
          #         primary_key_method = @association ? @association.associated_primary_key : @model_config.abstract_model.primary_key
          #         label_method = @model_config.object_label_method
          #         @objects.collect { |o| {id: o.send(primary_key_method).to_s, label: o.send(label_method).to_s} }
          #       else
          #         @objects.to_json(@schema)
          #       end
          #     end
          #     if params[:send_data]
          #       send_data output, filename: "#{params[:model_name]}_#{DateTime.now.strftime('%Y-%m-%d_%Hh%Mm%S')}.json"
          #     else
          #       render json: output, root: false
          #     end
          #   end
          #
          #   format.xml do
          #     output = @objects.to_xml(@schema)
          #     if params[:send_data]
          #       send_data output, filename: "#{params[:model_name]}_#{DateTime.now.strftime('%Y-%m-%d_%Hh%Mm%S')}.xml"
          #     else
          #       render xml: output
          #     end
          #   end
          #
          #   format.csv do
          #     header, encoding, output = CSVConverter.new(@objects, @schema).to_csv(params[:csv_options].permit!.to_h)
          #     if params[:send_data]
          #       send_data output,
          #                 type: "text/csv; charset=#{encoding}; #{'header=present' if header}",
          #                 disposition: "attachment; filename=#{params[:model_name]}_#{DateTime.now.strftime('%Y-%m-%d_%Hh%Mm%S')}.csv"
          #     elsif Rails.version.to_s >= '5'
          #       render plain: output
          #     else
          #       render text: output
          #     end
          #   end
          # end

          render current_action.template_name, status: @status_code || :ok
        end
      end

      register_property :link_icon do
        'th-list'
      end
    end
  end
end