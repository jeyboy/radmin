module Radmin
  module ApplicationHelper
    include Radmin::Utils::Base

    def action
      Radmin::Actions.find(params[:action])
    end

    def abstract_model(name)
      Radmin::Config::model(name)
    end
  end
end
