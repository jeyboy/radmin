module Radmin
  module Actions
    @actions = {}

    def self.register(name, action = nil)
      if action.nil? && name.is_a?(Class)
        action = name
        name = action.to_s.demodulize.underscore.to_sym
      end

      return if @actions[name].present?

      instance_eval %{
        def #{name}(&block)
          add_action_custom_key(#{action}.instance, &block)
        end
      }
    end

    def self.action(name)
      @actions[name.to_sym]
    end

    def self.list(act_type = :all, bindings = {})
      res_actions = @actions.values

      if act_type != :all
        act = "#{act_type}#{'?' unless act_type.to_s.end_with?('?')}"

        res_actions = res_actions.select(&:"#{act}")
      end

      bindings[:controller] ? res_actions.select { |a| a.with_bindings(bindings).visible? } : res_actions
    end

    def self.find(name, bindings = {})
      return unless (res_action = action(name))

      bindings[:controller] ? res_action.with_bindings(bindings).visible? : res_action
    end

    private

    def self.add_action_custom_key(action, &block)
      action.instance_eval(&block) if block

      @actions[action.key] = action unless @actions[action.key]
      # raise "Action #{action.custom_key} already exists. Please change its custom key."
    end
  end
end

require 'radmin/actions/dashboard'
require 'radmin/actions/index'
require 'radmin/actions/show'
require 'radmin/actions/bulk_delete'
require 'radmin/actions/delete'
require 'radmin/actions/edit'
require 'radmin/actions/export'
require 'radmin/actions/new'
