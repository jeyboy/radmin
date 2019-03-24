require 'radmin/sections/list'
require 'radmin/sections/show'
require 'radmin/sections/new'
require 'radmin/sections/edit'

module Radmin
  module Sections
    def self.included(klass)
      # Register accessors for all the sections in this namespace
      available_sections.each do |name, section|
        klass.send(:define_method, name) do |&block|
          @sections ||= {}
          @sections[name] = section.new(self) unless @sections[name]
          @sections[name].instance_eval(&block) if block
          @sections[name]
        end
      end
    end

    private

    def self.available_sections
      @available_sections ||= begin
        children = Radmin::Sections::Base.descendants

        children.each_with_object({}) do |desc, res|
          res[desc.key] = desc
        end
      end
      # ObjectSpace.each_object(Class).select { |klass| klass < Radmin::Sections::Base }
      #
      # constants.each do |name|
      #   section = Radmin::Sections.const_get(name)
    end
  end
end