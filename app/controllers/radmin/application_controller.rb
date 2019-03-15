module Radmin
  class ApplicationController < (Config.parent_controller.constantize || ActionController::Base)
    protect_from_forgery Config.forgery_protection_settings || { with: :exception }
  end
end
