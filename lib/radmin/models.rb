require 'radmin/models/abstract'

module Radmin
  module Models
    @models = {}

    def self.get_model(key, entity)
      @models[key] ||=
        Radmin::Models::Abstract.new(entity)
    end

    def self.visible(bindings)
      @models.values.select do |m|
        m.with_bindings(bindings).visible? &&
          Radmin::Actions.find(:index, bindings.merge(abstract_model: m)).try(:authorized?) ||
            true
      end
    end

    # # Get all models that are configured as visible sorted by their weight and label.
    # def self.visible(bindings)
    #   visible_models_with_bindings(bindings).sort do |a, b|
    #     if (weight_order = a.weight <=> b.weight) == 0
    #       a.label.downcase <=> b.label.downcase
    #     else
    #       weight_order
    #     end
    #   end
    # end

    private

      # def self.visible_models_with_bindings(bindings)
      #   models.collect { |m| m.with(bindings) }.select do |m|
      #     m.visible? &&
      #         RailsAdmin::Config::Actions.find(:index, bindings.merge(abstract_model: m.abstract_model)).try(:authorized?) &&
      #         (!m.abstract_model.embedded? || m.abstract_model.cyclic?)
      #   end
      # end
  end
end