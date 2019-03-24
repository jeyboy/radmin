module Radmin
  module ApplicationHelper
    include Radmin::Utils::Base

    def action
      Radmin::Actions.action(params[:action])
    end

    def actions(scope = :all, abstract_model = nil, object = nil)
      Radmin::Actions.list(scope, controller: controller, abstract_model: abstract_model, object: object)
    end

    def abstract_model(name)
      Radmin::Config::model(name)
    end

    def wording_for(label, action = @action, abstract_model = current_model, object = @object)
      object = abstract_model && object.is_a?(abstract_model.model) ? object : nil
      action = Radmin::Actions.find(action.to_sym) if action.is_a?(Symbol) || action.is_a?(String)

      capitalize_first_letter(
        I18n.t(
          "admin.actions.#{action.i18n_key}.#{label}",
          model_label: abstract_model&.label,
          model_label_plural: abstract_model&.label_plural,
          object_label: object&.try(abstract_model&.object_label_method),
        )
      )
    end

    def capitalize_first_letter(wording)
      return nil unless wording.present? && wording.is_a?(String)

      wording = wording.dup
      wording[0] = wording[0].mb_chars.capitalize.to_s
      wording
    end
  end
end
