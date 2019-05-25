require 'radmin/models/abstract'

module Radmin
  module Models
    @models = {}
    @polymorphics = {}

    def self.has_models?
      @models.present?
    end

    def self.get_model(key, entity, &block)
      @models[key] || if block
        mdl = Radmin::Models::Abstract.new(entity)

        mdl.instance_eval(&block)

        @models[key] = mdl
      end
    end

    def self.visible(bindings)
      @models.values.select do |m|
        m.with_bindings(bindings).visible? &&
          Radmin::Actions.find(:index, bindings.merge(abstract_model: m)).try(:authorized?) ||
            true
      end
    end

    # TODO: refactor me
    def self.viable
      Radmin::Config::included_models.collect(&:to_s).presence || begin
        !Rails.application ? [] :
          @@system_models ||=
            ([Rails.application] + Rails::Engine.subclasses.collect(&:instance)).flat_map do |app|
              (app.paths['app/models'].to_a + app.paths.eager_load).collect do |load_path|
                Dir.glob(app.root.join(load_path)).collect do |load_dir|
                  Dir.glob(load_dir + '/**/*.rb').collect do |filename|
                    # app/models/module/class.rb => module/class.rb => module/class => Module::Class
                    lchomp(filename, "#{app.root.join(load_dir)}/").chomp('.rb').camelize
                  end
                end
              end
            end.flatten.reject { |m| m.starts_with?('Concerns::') }
      end
    end

    def self.init!
      unless Radmin::Models.has_models?
        Radmin::Config::included_models = Radmin::Models.viable


        #TODO: init all viable models
        #
        #   radmin do
        #     object_label_method :to_s
        #
        #     list do
        #       include_all_fields
        #     end
        #
        #     new do
        #       include_all_fields
        #     end
        #
        #     edit do
        #       include_all_fields
        #     end
        #
        #     show do
        #       include_all_fields
        #     end
        #   end
      end

      @polymorphics = {}

      Radmin::Models.viable.each do |klass|
        init_class_polymorphics(klass)
      end
    end

    def self.init_class_polymorphics(klass)
      if !Radmin.config(klass) && klass.respond_to?(:reflections)
        klass.reflections.each do |reflection|
          if (name = reflection.options[:as]) || (name = reflection.options['as'])
            register_polymorphic(name, klass)
          end
        end
      end
    end

    def self.register_polymorphic(name, klass)
      polymorphic_classes(name) << klass
    end

    def self.polymorphic_classes(name)
      (@polymorphics[name] ||= [])
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

      def self.lchomp(base, arg)
        base.to_s.reverse.chomp(arg.to_s.reverse).reverse
      end

      # def self.visible_models_with_bindings(bindings)
      #   models.collect { |m| m.with(bindings) }.select do |m|
      #     m.visible? &&
      #         RailsAdmin::Config::Actions.find(:index, bindings.merge(abstract_model: m.abstract_model)).try(:authorized?) &&
      #         (!m.abstract_model.embedded? || m.abstract_model.cyclic?)
      #   end
      # end
  end
end