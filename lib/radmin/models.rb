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
        collector_mode = Radmin::Config::default_model_collector_mode

        res = main_app_models_list if collector_mode == :all || collector_mode == :main_app || collector_mode != :subengines
        (res ||= []).concat(engines_models_list) if collector_mode == :all || collector_mode == :subengines

        res
      end
    end


    def self.init!
      if !Radmin::Models.has_models? && Radmin::Config::default_init_proc.is_a?(Proc)
        excl_mdls =
          Radmin::Config::excluded_models.each_with_object({}) { |m, res| res[m.to_s] = true }
            .merge(Radmin::Config::model_class_blockers)

        mdls =
          Radmin::Config::included_models.presence ||
            Radmin::Models.viable.each_with_object({}) do |mn, res|
              next if excl_mdls.has_key?(mn)

              mc = class_obj(mn) # || mn.constantize
              res[mc] = true if mc && res[mc].nil?
            end.keys

        mdls.uniq.sort.each do |mdl|
          if !mdl.respond_to?(:radmin)
            if Radmin::Config::attach_non_model_classes
              mdl.send(:include, Radmin::Base)
            else
              next
            end
          end

          mdl.class_eval(&Radmin::Config::default_init_proc)
        end
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
      def self.main_app_models_list
        !Rails.application ? [] :
          @@app_models_list ||= app_models_list(Rails.application)
      end

      def self.engines_models_list
        @@engines_models_list ||=
          Rails::Engine.subclasses.each_with_object([]) do |entity, res|
            app_models_list(entity.instance, res)
          end
      end

      def self.app_models_list(app, res_arr = [])
        Radmin::Config.default_model_paths.call(app).each_with_object(res_arr) do |load_dir, res|
          # Dir.glob(app.root.join(load_path)).collect do |load_dir|
            Dir.glob(load_dir + '/**/*.rb').collect do |filename|
              name = lchomp(filename, "#{app.root.join(load_dir)}/").chomp('.rb').camelize

              res << name if name && !name.starts_with?('Concerns::')
            end
          # end
        end
      end

      def self.class_obj(class_name)
        return nil unless Object.const_defined?(class_name)

        klass = Object.const_get(class_name)
        klass.is_a?(Class) ? klass : nil
      rescue NameError
        nil
      end

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