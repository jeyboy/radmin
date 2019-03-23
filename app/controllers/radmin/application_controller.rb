module Radmin
  class ModelNotFound < ::StandardError
  end

  class ObjectNotFound < ::StandardError
  end

  class ActionNotAllowed < ::StandardError
  end

  class ApplicationController < (Config.parent_controller.constantize || ActionController::Base)
    include Radmin::ApplicationHelper

    protect_from_forgery Config.forgery_protection_settings || { with: :exception }

    attr_reader :current_model
    helper_method :current_model

    before_action :_authenticate!
    before_action :_authorize!
    before_action :_audit!

    rescue_from Radmin::ObjectNotFound do
      flash[:error] = I18n.t('admin.flash.object_not_found', model: @model_name, id: params[:id])
      params[:action] = 'index'
      @status_code = :not_found
      index
    end

    rescue_from Radmin::ModelNotFound do
      flash[:error] = I18n.t('admin.flash.model_not_found', model: @model_name)
      params[:action] = 'dashboard'
      @status_code = :not_found
      dashboard
    end

    def get_model
      @model_name = path_name_to_class_name(params[:model_name])

      raise(Radmin::ModelNotFound) unless
        (@current_model = abstract_model(@model_name))

      raise(Radmin::ModelNotFound) unless
          current_model.visible?

      # @properties = current_model.properties
    end

    def get_object
      raise(Radmin::ObjectNotFound) unless
        (@object = current_model.find(params[:id]))
    end

    def _current_user
      instance_eval(&Radmin::Config.current_user_method)
    end
    helper_method :_current_user

    private

    def _authenticate!
      instance_eval(&Radmin::Config.authenticate_with)
    end

    def _authorize!
      instance_eval(&Radmin::Config.authorize_with)
    end

    def _audit!
      instance_eval(&Radmin::Config.audit_with)
    end
  end
end
