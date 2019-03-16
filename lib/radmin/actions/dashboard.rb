require 'radmin/actions/base'

module Radmin
  module Actions
    class Dashboard < Radmin::Actions::Base
      Radmin::Actions::register_action(self)

      register_property :statistics do
        true
      end

      register_property :root? do
        true
      end

      register_property :breadcrumb_parent do
        nil
      end

      register_property :controller do
        proc do
          # @history = @auditing_adapter && @auditing_adapter.latest(@action.auditing_versions_limit) || []
          # if @action.statistics?
          #   @abstract_models = RailsAdmin::Config.visible_models(controller: self).collect(&:abstract_model)
          #
          #   @most_recent_created = {}
          #   @count = {}
          #   @max = 0
          #   @abstract_models.each do |t|
          #     scope = @authorization_adapter && @authorization_adapter.query(:index, t)
          #     current_count = t.count({}, scope)
          #     @max = current_count > @max ? current_count : @max
          #     @count[t.model.name] = current_count
          #     next unless t.properties.detect { |c| c.name == :created_at }
          #     @most_recent_created[t.model.name] = t.model.last.try(:created_at)
          #   end
          # end
          # render @action.template_name, status: @status_code || :ok
        end
      end

      register_property :route_fragment do
        ''
      end

      register_property :link_icon do
        'icon-home'
      end
    end
  end
end