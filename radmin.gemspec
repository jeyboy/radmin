$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'radmin/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'radmin'
  spec.version     = Radmin::VERSION
  spec.authors     = ['jeyboy', 'BlackKOT']
  spec.email       = ['jeyboy@bigmir.net', 'oko10ko@ukr.net']
  spec.homepage    = 'https://github.com/jeyboy/radmin'
  spec.summary     = 'Admin panel'
  spec.description = 'Admin panel'
  spec.license     = 'MIT'

  # # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'rails', '>= 4'
  spec.add_dependency 'kaminari'

  spec.add_dependency 'remotipart', '~> 1.4.2'

  spec.add_dependency 'haml'
  spec.add_dependency 'jquery-rails'
  spec.add_dependency 'coffee-rails'
  spec.add_dependency 'sass-rails'

  spec.add_dependency 'bootstrap', '~> 4.3.1'
  spec.add_dependency 'font_awesome5_rails', '~> 0.5.0'

  spec.add_dependency 'rails_or'

  # spec.add_dependency 'builder'
  # spec.add_dependency 'rack-pjax'
  # spec.add_dependency 'nested_form'

  spec.add_development_dependency 'pg'

  spec.required_ruby_version = '>= 2.3.0'
end
