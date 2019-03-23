require 'rails'
require 'radmin'
require 'jquery-rails'
require 'font_awesome5_rails'
# require 'jquery-ui-rails'
require 'kaminari'
# require 'nested_form'
require 'remotipart'
require 'bootstrap'

module Radmin
  class Engine < ::Rails::Engine
    isolate_namespace Radmin

    config.action_dispatch.rescue_responses['Radmin::ActionNotAllowed'] = :forbidden

    initializer 'Radmin precompile hook', group: :all do |app|
      app.config.assets.precompile += %w(
        radmin/radmin.js
        radmin/radmin.css
      )
    end

    # initializer 'RailsAdmin setup middlewares' do |app|
    #   app.config.middleware.use Rack::Pjax
    # end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), '../tasks/*.rake')].each { |f| load f }
    end

#     # Check for required middlewares, users may forget to use them in Rails API mode
#     config.after_initialize do |app|
#       has_session_store = ::Rails.version < '5.0' || app.config.middleware.to_a.any? do |m|
#         m.klass.try(:<=, ActionDispatch::Session::AbstractStore) ||
#             m.klass.name =~ /^ActionDispatch::Session::/
#       end
#       loaded = app.config.middleware.to_a.map(&:name)
#       required = %w(ActionDispatch::Cookies ActionDispatch::Flash Rack::MethodOverride)
#       missing = required - loaded
#       unless missing.empty? && has_session_store
#         configs = missing.map { |m| "config.middleware.use #{m}" }
#         configs << "config.middleware.use #{app.config.session_store.try(:name) || 'ActionDispatch::Session::CookieStore'}, #{app.config.session_options}" unless has_session_store
#         raise <<-EOM
# Required middlewares for RailsAdmin are not added
# To fix this, add
#   #{configs.join("\n  ")}
# to config/application.rb.
#         EOM
#       end
#     end
  end
end
