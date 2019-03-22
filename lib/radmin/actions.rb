module Radmin
  module Actions
    @@actions = {}

    def self.register(name, action = nil)
      if action.nil? && name.is_a?(Class)
        action = name
        name = action.to_s.demodulize.underscore.to_sym
      end

      return if @@actions[name].present?

      instance_eval %{
        def #{name}(&block)
          add_action_custom_key(#{action}.instance, &block)
        end
      }
    end

    def self.all
      @@actions
    end

    def self.list(act_type = :all)
      return @@actions.values if act_type == :all

      act = "#{act_type}#{'?' unless act_type.to_s.end_with?('?')}"

      @@actions.values.select(&:"#{act}")
    end

    private

    def self.add_action_custom_key(action, &block)
      action.instance_eval(&block) if block

      @@actions[action.custom_key] = action unless @@actions[action.custom_key]
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
