module Radmin
  module Actions
    @@actions = {}

    def self.register_action(action)
      instance_eval %{
        def #{name}(&block)
          action.instance.instance_eval(&block) if block
        end
      }

      @@actions[action.instance.key] = action.instance
    end

    def self.all
      @@actions
    end

    def self.list(act_type = :all)
      return @@actions.values if act_type == :all

      act = "#{act_type}#{'?' unless act_type.to_s.end_with?('?')}"

      @@actions.values.select(&:"#{act}")
    end
  end
end

require 'radmin/actions/dashboard'
require 'radmin/actions/index'
require 'radmin/actions/show'
