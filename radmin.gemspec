$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'radmin/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'radmin'
  spec.version     = Radmin::VERSION
  spec.authors     = ['JB']
  spec.email       = ['jeyboy@bigmir.net']
  spec.homepage    = 'https://github.com/jeyboy'
  spec.summary     = 'Admin panel'
  spec.description = 'Admin panel'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'rails', '>= 4'
  spec.add_dependency 'kaminari'

  spec.add_dependency 'remotipart'

  spec.add_dependency 'coffee-rails'
  spec.add_dependency 'sass-rails'

  # spec.add_dependency 'builder'
  # spec.add_dependency 'rack-pjax'
  # spec.add_dependency 'nested_form'

  spec.add_development_dependency "pg"
end
