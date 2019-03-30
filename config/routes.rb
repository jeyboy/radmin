Radmin::Engine.routes.draw do
  controller 'main' do
    Radmin::Actions.list(:root?).each { |action| match "/#{action.route_fragment}", action: action.action_name, as: action.action_name, via: action.http_methods }
    scope ':model_name' do
      Radmin::Actions.list(:collection).each { |action| match "/#{action.route_fragment}(/page/:page)", action: action.action_name, as: action.action_name, via: action.http_methods, constraints: { page: /\d+/ } }

      post '/bulk_action', action: :bulk_action, as: 'bulk_action'
      scope ':id' do
        Radmin::Actions.list(:member).each { |action| match "/#{action.route_fragment}", action: action.action_name, as: action.action_name, via: action.http_methods }
      end
    end
  end
end
