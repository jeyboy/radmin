module Radmin
  module ApplicationHelper
    include Radmin::Utils::Base

    def rbindings
      @rbindings ||= {
        controller: self,
        view: view_context
      }
    end

    def bindings
      @bindings ||= {
        abstract_model: current_model,
        object: @object,
        objects: @objects,
        **rbindings
      }
    end

    def authorized?(action_name, abstract_model = nil, object = nil)
      object = nil if object.try :new_record?
      action(action_name, abstract_model, object).try(:authorized?)
    end

    def current_action?(target_action, abstract_model = current_model, object = @object)
      current_action.key == target_action.key &&
        abstract_model.try(:to_param) == current_model.try(:to_param) &&
        (@object.try(:persisted?) ? @object.id == object.try(:id) : !object.try(:persisted?))
    end

    def action(key, abstract_model = nil, object = nil)
      Radmin::Actions.find(key, abstract_model: abstract_model, object: object, **rbindings)
    end

    def actions(scope = :all, abstract_model = nil, object = nil)
      Radmin::Actions.list(scope, abstract_model: abstract_model, object: object, **rbindings)
    end

    def abstract_model(name)
      Radmin::Config::model(name)
    end

    def wording_for(label, target_action = current_action, abstract_model = current_model, object = @object)
      object = abstract_model && object.is_a?(abstract_model.model) ? object : nil
      target_action = Radmin::Actions.find(target_action.to_sym) unless (target_action.class < Radmin::Actions::Base) # if target_action.is_a?(Symbol) || target_action.is_a?(String)

      capitalize_first_letter(
        I18n.t(
          "admin.actions.#{target_action.i18n_key}.#{label}",
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
