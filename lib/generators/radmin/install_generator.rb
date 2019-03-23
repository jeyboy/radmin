require 'rails/generators'
require File.expand_path('../utils', __FILE__)

module Radmin
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    include Generators::Utils::InstanceMethods

    argument :_namespace, type: :string, required: false, desc: 'Radmin url namespace'
    desc 'Radmin installation generator'

    def install
      namespace = ask_for('Where do you want to mount radmin?', 'admin', _namespace)
      route("mount Radmin::Engine => '/#{namespace}', as: 'radmin'")
      template 'initializer.erb', 'config/initializers/radmin.rb'
    end
  end
end
