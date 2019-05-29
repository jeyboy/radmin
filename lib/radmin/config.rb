require 'radmin/actions'
require 'radmin/models'

module Radmin
  class Config
    DEFAULT_PROC = proc {}
    DEFAULT_FILTER_SCHEMA = :or_and
    DEFAULT_SEARCH_SCHEMA = :or

    class << self
      # show Gravatar in Navigation bar
      attr_accessor :show_gravatar

      # Application title
      attr_accessor :app_title

      # set brand text
      attr_accessor :brand_text

      # set brand icon
      attr_accessor :brand_icon_url

      # set parent controller
      attr_accessor :parent_controller

      # set settings for `protect_from_forgery` method
      # By default, it raises exception upon invalid CSRF tokens
      attr_accessor :forgery_protection_settings

      # class names which stops chain of parents
      attr_accessor :model_class_blockers

      attr_accessor :default_search_operator

      # :or # 'or' between rules
      # :and # 'and' between rules
      attr_accessor :default_search_schema
      
      # schema used for union between filter rules
      # :or_and # 'or' between rules grouped by field and 'and' between groups of rules for different fields
      # :or_or # 'or' between rules grouped by field and 'or' between groups of rules for different fields
      # :and_and # 'and' between rules grouped by field and 'and' between groups of rules for different fields
      # # (not implemented) :manual # user can config relation between each pair of rules with UI
      attr_accessor :default_filter_schema

      # See #init_filter_cmds
      attr_accessor :filter_cmds
      attr_accessor :filter_like_cmd

      # Fields to be hidden in show, create and update views
      attr_accessor :default_hidden_fields

      # Configuration option to specify which method names will be searched for
      # to be used as a label for object records. This defaults to [:to_s]
      attr_accessor :label_methods

      # Configuration option to specify logic regarding regular attribute output.
      # If false always will output raw attribute value for regular attribute
      # otherwise will try to take value from alias for attribute if it will be set.
      # The logic regarding associations will not changed
      # This defaults to false
      attr_accessor :search_label_method_for_attribute

      # Default items per page value used if a model level option has not
      # been configured
      attr_accessor :default_items_per_page

      attr_accessor :default_link_class

      # :top and :bottom positions is available
      attr_accessor :default_submit_buttons_location

      # hide blank fields in show view if true
      attr_accessor :compact_show_view

      # Configuration option to specify which models you want to exclude.
      attr_accessor :excluded_models

      # Configuration option to specify a whitelist of models you want to Radmin to work with.
      # The excluded_models list applies against the whitelist as well and further reduces the models
      # Radmin will use.
      # If included_models is left empty ([]), then Radmin will automatically use all the models
      # in your application (less any excluded_models you may have specified).
      attr_accessor :included_models

      # Use classes found in models folder and not inherited from base Active Record class
      attr_accessor :attach_non_model_classes

      # Default init config for automatically proceeding models
      attr_accessor :default_init_proc

      # Default pathes where to search models
      # ->(app) {
      #   app.paths['app/models'].to_a + app.paths.eager_load
      # }
      attr_accessor :default_model_paths

      # Configure default places where to search models
      # :all
      # :main_app
      # :subengines
      attr_accessor :default_model_collector_mode


      # # Default association limit
      # attr_accessor :default_associated_collection_limit
      #
      # # Tell browsers whether to use the native HTML5 validations (novalidate form option).
      # attr_accessor :browser_validations
      #
      # # Set the max width of columns in list view before a new set is created
      # attr_accessor :total_columns_width


      def default_submit_buttons_location=(**args)
        args.symbolize_keys!

        @default_submit_buttons_location = {
          top: args[:top], bottom: args[:bottom]
        }
      end


      def default_hidden_fields=(fields)
        if fields.is_a?(Array)
          @default_hidden_fields = {}
          @default_hidden_fields[:index] = fields
          @default_hidden_fields[:edit] = fields
          @default_hidden_fields[:show] = fields
        else
          @default_hidden_fields = fields.stringify_keys
        end
      end


      def label_methods=(methods)
        if methods.is_a?(Array)
          @label_methods = { nil => methods }
        elsif methods.is_a?(Hash)
          @label_methods = methods.with_indifferent_access
        else
          raise 'Invalid label methods config'
        end
      end


      def default_search_operator=(operator)
        operator = operator.to_s

        if operator.start_with? '_'
          @default_search_operator = operator
        else
          @default_search_operator =
            case operator.downcase
              when 'default', 'is', '='
                '_exactly'
              when 'like'
                '_contains'
              when 'starts_with'
                '_starts_with'
              when 'ends_with'
                '_ends_with'
              else
                raise(ArgumentError.new("Search operator '#{operator}' not supported"))
            end
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


      def default_search_schema=(new_schema)
        @default_search_schema = new_schema.presence || DEFAULT_SEARCH_SCHEMA
      end

      def default_filter_schema=(new_schema)
        @default_filter_schema = new_schema.presence || DEFAULT_FILTER_SCHEMA
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
      def reset
        @app_title = nil # proc { [Rails.application.engine_name.titleize.chomp(' Application'), 'Admin'] }
        @brand_text = 'RAdmin'
        @brand_icon_url = nil

        @model_class_blockers = {
          'Object' => true,
          'BasicObject' => true,
          'ActiveRecord::Base' => true,
          'ApplicationRecord' => true
        }

        @compact_show_view = true
        # @browser_validations = true
        # @yell_for_non_accessible_fields = true
        @authenticate = nil
        @authorize = nil
        @audit = nil
        @current_user = nil

        # @default_hidden_fields = {}
        # @default_hidden_fields[:base] = [:_type]
        # @default_hidden_fields[:edit] = [:id, :_id, :created_at, :created_on, :deleted_at, :updated_at, :updated_on, :deleted_on]
        # @default_hidden_fields[:show] = [:id, :_id, :created_at, :created_on, :deleted_at, :updated_at, :updated_on, :deleted_on]
        @default_items_per_page = 20
        @default_link_class = 'info'
        # @default_associated_collection_limit = 100
        @default_search_operator = '_exactly'

        @excluded_models = []
        @included_models = []
        # @total_columns_width = 697
        #
        @label_methods = {
          nil => :to_s
        }

        @show_gravatar = true
        @parent_controller = '::ActionController::Base'
        @forgery_protection_settings = {with: :exception}
        
        init_filter_cmds

        @default_filter_schema = DEFAULT_FILTER_SCHEMA

        @default_submit_buttons_location = { bottom: true }

        @attach_non_model_classes = true
        @search_label_method_for_attribute = false

        @default_init_proc = ->(klass) {
          klass.send :radmin do
            object_label_method :to_s

            list do
              include_all_fields
            end

            new do
              include_all_fields
            end

            edit do
              include_all_fields
            end

            show do
              include_all_fields
            end
          end
        }

        @default_model_paths = ->(app) { app.paths['app/models'].to_a }

        @default_model_collector_mode = :all

        # Radmin::Actions.reset
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

          result.last << "#{val}"
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


        @filter_cmds['_this_week'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} BETWEEN ? AND ?)"
          result.last << Time.zone.now.beginning_of_week << Time.zone.now.end_of_week
        }

        @filter_cmds['_last_week'] = ->(result, name, val, type, adapter_type) {
          result.first << "(#{name} BETWEEN ? AND ?)"
          result.last << (Time.zone.now.beginning_of_week - 1.week) << (Time.zone.now.end_of_week - 1.week)
        }
      end

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
    end

    reset
  end
end