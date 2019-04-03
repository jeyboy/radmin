module Radmin
  module MainHelper
    def include_js_translations
      "window.I18n = #{I18n.t('admin.js').to_json};".html_safe
    end

    def main_navigation
      nodes_stack = Radmin::Models.visible(bindings)
      node_model_names = nodes_stack.collect { |c| c.model_name }

      nodes_stack.group_by(&:navigation_label).collect do |navigation_label, nodes|
        nodes = nodes.select { |n| n.parent.nil? || !n.parent.to_s.in?(node_model_names) }
        li_stack = navigation nodes_stack, nodes

        label = navigation_label || t('admin.misc.navigation')

        %(<li class='dropdown-header'>#{capitalize_first_letter label}</li>#{li_stack}) if li_stack.present?
      end.join.html_safe
    end

    def static_navigation
      li_stack = Radmin::Config.navigation_static_links.collect do |title, url|
        ico = nil

        if url.is_a?(Array)
          ico, url = url
        elsif url.is_a?(Hash)
          ico, url = url.values_at(:ico, :url)
        end

        nav_icon = ico ? fa_icon(ico, type: :solid).html_safe : ''
        content_tag(:li, link_to(nav_icon + ' ' + title.to_s, url, target: '_blank'), class: 'nav-link')
      end.join

      label = Radmin::Config.navigation_static_label || t('admin.misc.navigation_static_label')
      li_stack = %(<li class='dropdown-header'>#{label}</li>#{li_stack}).html_safe if li_stack.present?
      li_stack
    end

    def navigation(nodes_stack, nodes, level = 0)
      nodes.collect do |node|
        model_param = node.to_param
        url = radmin.url_for(action: :index, controller: 'radmin/main', model_name: model_param)
        level_class = " nav-level-#{level}" if level > 0
        nav_icon = node.navigation_icon ? fa_icon(node.navigation_icon, type: :solid).html_safe : ''

        li = content_tag :li, data: {model: model_param}, class: 'nav-link' do
          link_to nav_icon + ' ' + capitalize_first_letter(node.label_plural), url, class: "ajax #{level_class}"
        end

        li + navigation(nodes_stack, nodes_stack.select { |n| n.parent.to_s == node.model_name }, level + 1)
      end.join.html_safe
    end

    def breadcrumb(target_action = current_action, _acc = [])
      content_tag(:ol, class: 'breadcrumb') do
        items = ''

        begin
          am = target_action.bindings[:abstract_model]
          o = target_action.bindings[:object]

          items.prepend(
            content_tag(:li, class: 'breadcrumb-item active') do
              begin
                if !current_action?(target_action, am, o)
                  if target_action.http_methods.include?(:get)
                    link_to radmin.url_for(action: target_action.action_name, controller: 'radmin/main', model_name: am.try(:to_param), id: (o.try(:persisted?) && o.try(:id) || nil)), class: 'ajax' do
                      wording_for(:breadcrumb, target_action, am, o)
                    end
                  else
                    content_tag(:span, wording_for(:breadcrumb, target_action, am, o))
                  end
                else
                  wording_for(:breadcrumb, target_action, am, o)
                end
              end
            end
          )
        end while target_action.breadcrumb_parent && (target_action = action(*target_action.breadcrumb_parent)) # rubocop:disable Loop

        items.html_safe
      end
    end

    # scope => :root, :collection, :member
    def menu_for(scope, abstract_model = nil, object = nil, only_icon = false) # perf matters here (no action view trickery)
      target_actions =
        (@menu_for ||= {})[scope] ||= actions(scope).select { |a| a.http_methods.include?(:get) }

      target_actions.collect do |target_action|
        next unless target_action.with_bindings(abstract_model: abstract_model, object: object, **rbindings).visible?

        wording = wording_for(:menu, target_action)
        %(
            <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon nav-item #{target_action.key}_#{scope}_link">
              <a class="nav-link #{'active' if current_action?(target_action)} #{target_action.remote? ? 'ajax' : ''}" href="#{radmin.url_for(action: target_action.action_name, controller: 'radmin/main', model_name: abstract_model.try(:to_param), id: (object.try(:persisted?) && object.try(:id) || nil))}">
                #{fa_icon(target_action.link_icon, type: :solid)}
                <span#{only_icon ? " style='display:none'" : ''}>#{wording}</span>
              </a>
            </li>
          )
      end.join.html_safe
    end

    # def bulk_menu(abstract_model = current_model)
    #   bulk_actions = actions(:bulkable, abstract_model)
    #   return nil if bulk_actions.empty?
    #
    #   content_tag :li, class: 'dropdown', style: 'float:right' do
    #     content_tag(:a, class: 'dropdown-toggle', data: {toggle: 'dropdown'}, href: '#') { t('admin.misc.bulk_menu_title').html_safe + ' ' + '<b class="caret"></b>'.html_safe } +
    #         content_tag(:ul, class: 'dropdown-menu', style: 'left:auto; right:0;') do
    #           actions.collect do |action|
    #             content_tag :li do
    #               link_to wording_for(:bulk_link, action), '#', onclick: "jQuery('#bulk_action').val('#{action.action_name}'); jQuery('#bulk_form').submit(); return false;"
    #             end
    #           end.join.html_safe
    #         end
    #   end.html_safe
    # end

    def flash_alert_class(flash_key)
      case flash_key.to_s
        when 'error'  then 'alert-danger'
        when 'alert'  then 'alert-warning'
        when 'notice' then 'alert-info'
        else "alert-#{flash_key}"
      end
    end

    def filterable_fields
      @filterable_fields ||= current_model.list.fields.values.select(&:filterable)
    end

    def ordered_filters
      # return @ordered_filters if @ordered_filters.present?
      # @index = 0
      # @ordered_filters = (params[:f].try(:permit!).try(:to_h) || @model_config.list.filters).inject({}) do |memo, filter|
      #   field_name = filter.is_a?(Array) ? filter.first : filter
      #   (filter.is_a?(Array) ? filter.last : {(@index += 1) => {'v' => ''}}).each do |index, filter_hash|
      #     if filter_hash['disabled'].blank?
      #       memo[index] = {field_name => filter_hash}
      #     else
      #       params[:f].delete(field_name)
      #     end
      #   end
      #   memo
      # end.to_a.sort_by(&:first)
      []
    end

    def ordered_filter_string
      # @ordered_filter_string ||= ordered_filters.map do |duplet|
      #   options = {index: duplet[0]}
      #   filter_for_field = duplet[1]
      #   filter_name = filter_for_field.keys.first
      #   filter_hash = filter_for_field.values.first
      #   unless (field = filterable_fields.find { |f| f.name == filter_name.to_sym })
      #     raise "#{filter_name} is not currently filterable; filterable fields are #{filterable_fields.map(&:name).join(', ')}"
      #   end
      #   case field.type
      #     when :enum
      #       options[:select_options] = options_for_select(field.with(object: @abstract_model.model.new).enum, filter_hash['v'])
      #     when :date, :datetime, :time
      #       options[:datetimepicker_format] = field.parser.to_momentjs
      #   end
      #   options[:label] = field.label
      #   options[:name]  = field.name
      #   options[:type]  = field.type
      #   options[:value] = filter_hash['v']
      #   options[:label] = field.label
      #   options[:operator] = filter_hash['o']
      #   %{$.filters.append(#{options.to_json});}
      # end.join("\n").html_safe if ordered_filters
    end
  end
end