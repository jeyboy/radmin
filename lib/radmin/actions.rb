require 'radmin/actions/dashboard'
require 'radmin/actions/index'
require 'radmin/actions/show'

module Radmin
  module Actions
    @@actions = {}

    def self.register_action(action)
      @@actions[action.key] = action
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

    def self.init
      Radmin::Actions.register_action(Radmin::Actions::Dashboard.instance)
      Radmin::Actions.register_action(Radmin::Actions::Index.instance)
      Radmin::Actions.register_action(Radmin::Actions::Show.instance)
    end

    init
  end
end