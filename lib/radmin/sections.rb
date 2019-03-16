module Radmin
  module Sections
    def self.included(klass)
      i = 0

      # # Register accessors for all the sections in this namespace
      # constants.each do |name|
      #   section = RailsAdmin::Config::Sections.const_get(name)
      #   name = name.to_s.underscore.to_sym
      #   klass.send(:define_method, name) do |&block|
      #     @sections = {} unless @sections
      #     @sections[name] = section.new(self) unless @sections[name]
      #     @sections[name].instance_eval(&block) if block
      #     @sections[name]
      #   end
      # end
    end
  end
end