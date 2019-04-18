require 'radmin/actions'
require 'radmin/models'

module Radmin
  class Config
    DEFAULT_PROC = proc {}

    # DEFAULT_AUTHENTICATION = proc {}
    #
    # DEFAULT_AUTHORIZE = proc {}
    #
    # DEFAULT_AUDIT = proc {}
    #
    # DEFAULT_CURRENT_USER = proc {}

    class << self
      # set brand text
      attr_accessor :brand_text

      # set brand icon
      attr_accessor :brand_icon_url

      # set parent controller
      attr_accessor :parent_controller

      # class names which stops chain of parents
      attr_accessor :model_class_blockers;


      attr_accessor :filter_cmds
      attr_accessor :filter_like_cmd
      
      # set settings for `protect_from_forgery` method
      # By default, it raises exception upon invalid CSRF tokens
      attr_accessor :forgery_protection_settings


      # Fields to be hidden in show, create and update views
      attr_accessor :default_hidden_fields


      # Default items per page value used if a model level option has not
      # been configured
      attr_accessor :default_items_per_page

      attr_accessor :default_link_class

      def default_hidden_fields=(hidden_fields)
        @default_hidden_fields = hidden_fields.stringify_keys
      end

      def default_search_operator=(operator)
        if %w(default like starts_with ends_with is =).include? operator
          @default_search_operator = operator
        else
          raise(ArgumentError.new("Search operator '#{operator}' not supported"))
        end
      end


      # Returns action configuration object
      def actions(&block)
        Radmin::Actions.instance_eval(&block) if block
      end

      # Loads a model configuration instance from the registry or registers
      # a new one if one is yet to be added.
      #
      # First argument can be an instance of requested model, its class object,
      # its class name as a string or symbol or a RailsAdmin::AbstractModel
      # instance.
      #
      # If a block is given it is evaluated in the context of configuration instance.
      #
      # Returns given model's configuration
      def model(entity, &block)
        key = begin
          if entity.is_a?(Class)
            if entity < Radmin::Models::Base
              entity.model.name.to_sym
            else
              entity.name.to_sym
            end
          elsif entity.is_a?(String) || entity.is_a?(Symbol)
            entity.to_sym
          else
            entity.class.name.to_sym
          end
        end

        Radmin::Models.get_model(key, entity, &block)

        # @registry[key] ||= RailsAdmin::Config::LazyModel.new(entity)
        # @registry[key].add_deferred_block(&block) if block
        # @registry[key]
      end

      # @see RailsAdmin::Config::DEFAULT_PROC
      def authorize_with(*args, &block)
        # extension = args.shift
        # if extension
        #   klass = RailsAdmin::AUTHORIZATION_ADAPTERS[extension]
        #   klass.setup if klass.respond_to? :setup
        #   @authorize = proc do
        #     @authorization_adapter = klass.new(*([self] + args).compact)
        #   end
        # elsif block
        #   @authorize = block
        # end
        @authorize || DEFAULT_PROC
      end


      # @see Radmin::Config::DEFAULT_PROC
      def authenticate_with(&blk)
        @authenticate = blk if blk
        @authenticate || DEFAULT_PROC
      end

      # Setup auditing/history/versioning provider that observe objects lifecycle
      def audit_with(*args, &block)
        # extension = args.shift
        # if extension
        #   klass = RailsAdmin::AUDITING_ADAPTERS[extension]
        #   klass.setup if klass.respond_to? :setup
        #   @audit = proc do
        #     @auditing_adapter = klass.new(*([self] + args).compact)
        #   end
        # elsif block
        #   @audit = block
        # end
        @audit || DEFAULT_PROC
      end



      # Setup a different method to determine the current user or admin logged in.
      # This is run inside the controller instance and made available as a helper.
      #
      # By default, _request.env["warden"].user_ or _current_user_ will be used.
      #
      # @example Custom
      #   Radmin.config do |config|
      #     config.current_user_method do
      #       current_admin
      #     end
      #   end
      #
      # @see Radmin::Config::DEFAULT_PROC
      def current_user_method(&block)
        @current_user = block if block
        @current_user || DEFAULT_PROC
      end



      # accepts a hash of static links to be shown below the main navigation
      def navigation_static_label=(label)
        @navigation_static_label = label
      end
      def navigation_static_label(&block)
        @navigation_static_label = block if block
        @navigation_static_label || DEFAULT_PROC
      end

      # accepts a hash of static links to be shown below the main navigation
      def navigation_static_links=(links)
        @navigation_static_links = links
      end

      def navigation_static_links(&block)
        @navigation_static_links = block if block
        @navigation_static_links || DEFAULT_PROC
      end


      # Reset all configurations to defaults.
      #
      # @see Radmin::Config.registry
      def reset
        @brand_text = 'RAdmin'
        @brand_icon_url = nil

        @model_class_blockers = {
          'Object' => true,
          'BasicObject' => true,
          'ActiveRecord::Base' => true,
          'ApplicationRecord' => true
        }

        # @compact_show_view = true
        # @browser_validations = true
        # @yell_for_non_accessible_fields = true
        @authenticate = nil
        @authorize = nil
        @audit = nil
        # @current_user = nil
        # @default_hidden_fields = {}
        # @default_hidden_fields[:base] = [:_type]
        # @default_hidden_fields[:edit] = [:id, :_id, :created_at, :created_on, :deleted_at, :updated_at, :updated_on, :deleted_on]
        # @default_hidden_fields[:show] = [:id, :_id, :created_at, :created_on, :deleted_at, :updated_at, :updated_on, :deleted_on]
        @default_items_per_page = 20
        @default_link_class = 'info'
        # @default_associated_collection_limit = 100
        # @default_search_operator = 'default'
        # @excluded_models = []
        # @included_models = []
        # @total_columns_width = 697
        # @label_methods = [:name, :title]
        # @main_app_name = proc { [Rails.application.engine_name.titleize.chomp(' Application'), 'Admin'] }
        # @registry = {}
        # @show_gravatar = true
        @parent_controller = '::ActionController::Base'
        @forgery_protection_settings = {with: :exception}
        
        init_filter_cmds        
        # RailsAdmin::Config::Actions.reset
      end

      def init_filter_cmds
        @filter_like_cmd = ->(result, name, val, type, adapter_type) {
          result.first <<
            case adapter_type
              when 'postgresql'
                "(#{name} ILIKE ?)"
              else
                "(LOWER(#{name}) LIKE LOWER(?))"
                # raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
            end

          result.last << "%#{val}%"
        }

        @filter_cmds = {}

        @filter_cmds['_skip'] = ->(result, name, val, type, adapter_type) {}
        @filter_cmds['_present'] = ->(result, name, val, type, adapter_type) { result.first << "(#{name} IS NOT NULL)" }
        @filter_cmds['_blank'] = ->(result, name, val, type, adapter_type) { result.first << "(#{name} IS NULL)" }
        @filter_cmds['_true'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} = ?)"
          result.last << true
        }
        @filter_cmds['_false'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} = ?)"
          result.last << false
        }
        @filter_cmds['_exactly'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} = ?)"
          result.last << val
        }
        @filter_cmds['_contains'] = ->(result, name, val, type, adapter_type) {
          @filter_like_cmd.call(result, name, "%#{val}%", type, adapter_type)
        }
        @filter_cmds['_starts_with'] = ->(result, name, val, type, adapter_type) {
          @filter_like_cmd.call(result, name, "#{val}%", type, adapter_type)
        }
        @filter_cmds['_ends_with'] = ->(result, name, val, type, adapter_type) {
          @filter_like_cmd.call(result, name, "%#{val}", type, adapter_type)
        }
        @filter_cmds['_less'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} < ?)"
          result.last << val
        }
        @filter_cmds['_bigger'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} > ?)"
          result.last << val
        }
        @filter_cmds['_between_x_and_y'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} BETWEEN ? AND ?)"
          result.last << val.first << val.last
        }

        @filter_cmds['_today'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} >= ?)"
          result.last << Time.zone.now.beginning_of_day
        }


        @filter_cmds['_yesterday'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} >= ?)"
          result.last << Time.zone.now.beginning_of_day - 1.day
        }


        # TODO: finish me

        @filter_cmds['_this_week'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} >= ?)"
          result.last << Time.zone.now.beginning_of_day
        }

        @filter_cmds['_last_week'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} >= ?)"
          result.last << Time.zone.now.beginning_of_day
        }
      end

      # # Application title, can be an array of two elements
      # attr_accessor :main_app_name
      #
      # # Configuration option to specify which models you want to exclude.
      # attr_accessor :excluded_models
      #
      # # Configuration option to specify a whitelist of models you want to RailsAdmin to work with.
      # # The excluded_models list applies against the whitelist as well and further reduces the models
      # # RailsAdmin will use.
      # # If included_models is left empty ([]), then RailsAdmin will automatically use all the models
      # # in your application (less any excluded_models you may have specified).
      # attr_accessor :included_models
      #
      # # Default association limit
      # attr_accessor :default_associated_collection_limit
      #
      # attr_reader :default_search_operator
      #
      # # Configuration option to specify which method names will be searched for
      # # to be used as a label for object records. This defaults to [:name, :title]
      # attr_accessor :label_methods
      #
      # # hide blank fields in show view if true
      # attr_accessor :compact_show_view
      #
      # # Tell browsers whether to use the native HTML5 validations (novalidate form option).
      # attr_accessor :browser_validations
      #
      # # Set the max width of columns in list view before a new set is created
      # attr_accessor :total_columns_width
      #
      # # Stores model configuration objects in a hash identified by model's class
      # # name.
      # #
      # # @see RailsAdmin.config
      # attr_reader :registry
      #
      # # show Gravatar in Navigation bar
      # attr_accessor :show_gravatar
      #
      # # yell about fields that are not marked as accessible
      # attr_accessor :yell_for_non_accessible_fields
      #
      # # Setup authentication to be run as a before filter
      # # This is run inside the controller instance so you can setup any authentication you need to
      # #
      # # By default, the authentication will run via warden if available
      # # and will run the default.
      # #
      # # If you use devise, this will authenticate the same as _authenticate_user!_
      # #
      # # @example Devise admin
      # #   RailsAdmin.config do |config|
      # #     config.authenticate_with do
      # #       authenticate_admin!
      # #     end
      # #   end
      # #
      # # @example Custom Warden
      # #   RailsAdmin.config do |config|
      # #     config.authenticate_with do
      # #       warden.authenticate! scope: :paranoid
      # #     end
      # #   end
      # #
      # # Setup authorization to be run as a before filter
      # # This is run inside the controller instance so you can setup any authorization you need to.
      # #
      # # By default, there is no authorization.
      # #
      # # @example Custom
      # #   RailsAdmin.config do |config|
      # #     config.authorize_with do
      # #       redirect_to root_path unless warden.user.is_admin?
      # #     end
      # #   end
      # #
      # # To use an authorization adapter, pass the name of the adapter. For example,
      # # to use with CanCan[https://github.com/ryanb/cancan], pass it like this.
      # #
      # # @example CanCan
      # #   RailsAdmin.config do |config|
      # #     config.authorize_with :cancan
      # #   end
      # #
      # # See the wiki[https://github.com/sferik/rails_admin/wiki] for more on authorization.
      # #
      # # Setup configuration using an extension-provided ConfigurationAdapter
      # #
      # # @example Custom configuration for role-based setup.
      # #   RailsAdmin.config do |config|
      # #     config.configure_with(:custom) do |config|
      # #       config.models = ['User', 'Comment']
      # #       config.roles  = {
      # #         'Admin' => :all,
      # #         'User'  => ['User']
      # #       }
      # #     end
      # #   end
      # def configure_with(extension)
      #   configuration = RailsAdmin::CONFIGURATION_ADAPTERS[extension].new
      #   yield(configuration) if block_given?
      # end
      #
      # # pool of all found model names from the whole application
      # def models_pool
      #   excluded = (excluded_models.collect(&:to_s) + %w(RailsAdmin::History PaperTrail::Version PaperTrail::VersionAssociation ActiveStorage::Attachment ActiveStorage::Blob))
      #
      #   (viable_models - excluded).uniq.sort
      # end
      #
      #
      # def default_hidden_fields=(fields)
      #   if fields.is_a?(Array)
      #     @default_hidden_fields = {}
      #     @default_hidden_fields[:edit] = fields
      #     @default_hidden_fields[:show] = fields
      #   else
      #     @default_hidden_fields = fields
      #   end
      # end
      #
      # # Returns all model configurations
      # #
      # # @see RailsAdmin::Config.registry
      # def models
      #   RailsAdmin::AbstractModel.all.collect { |m| model(m) }
      # end
      #
      # # Reset a provided model's configuration.
      # #
      # # @see RailsAdmin::Config.registry
      # def reset_model(model)
      #   key = model.is_a?(Class) ? model.name.to_sym : model.to_sym
      #   @registry.delete(key)
      # end
      #
      # # Reset all models configuration
      # # Used to clear all configurations when reloading code in development.
      # # @see RailsAdmin::Engine
      # # @see RailsAdmin::Config.registry
      # def reset_all_models
      #   @registry = {}
      # end
      #
      # # Get all models that are configured as visible sorted by their weight and label.
      # #
      # # @see RailsAdmin::Config::Hideable
      #
      # def visible_models(bindings)
      #   visible_models_with_bindings(bindings).sort do |a, b|
      #     if (weight_order = a.weight <=> b.weight) == 0
      #       a.label.downcase <=> b.label.downcase
      #     else
      #       weight_order
      #     end
      #   end
      # end
    end

    reset
  end
end