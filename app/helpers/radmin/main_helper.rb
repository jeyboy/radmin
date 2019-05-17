module Radmin
  module MainHelper
    def ra_form_for(*args, &block)
      options = args.extract_options!.reverse_merge(builder: Radmin::FormBuilder)
      # (options[:html] ||= {})[:novalidate] ||= !Radmin::Config.browser_validations

      form_for(*(args << options), &block)
    end

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
      end.join('<hr class="menu_breaker"/>').html_safe
    end

    def static_navigation
      static_links =
        Radmin::Config.navigation_static_links.is_a?(Proc) ?
          instance_eval(&Radmin::Config.navigation_static_links) :
            Radmin::Config.navigation_static_links

      li_stack = (static_links || []).collect do |title, url|
        ico = nil

        ico, url = url if url.is_a?(Array)

        nav_icon = ico ? fa_icon(ico, type: :solid) : ''
        content_tag(:li, link_to("#{nav_icon} #{title}".html_safe, url, target: '_blank'), class: 'nav-link')
      end.join

      if li_stack.present?
        label =
          (
            Radmin::Config.navigation_static_label.is_a?(Proc) ?
              instance_eval(&Radmin::Config.navigation_static_label) :
                Radmin::Config.navigation_static_label
          ) || t('admin.misc.navigation_static_label')

        li_stack = %(<li class='dropdown-header'>#{label}</li>#{li_stack}).html_safe
      end

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

      is_inline = only_icon && current_model.list.inline_menu
      item_class = is_inline ? 'inline-nav-item' : 'nav-item'

      target_actions.collect do |target_action|
        next unless target_action.with_bindings(abstract_model: abstract_model, object: object, **rbindings).visible?

        extra_item_class = "text-#{target_action.link_class} border-#{target_action.link_class}" if only_icon && target_action.link_class

        wording = wording_for(:menu, target_action)
        %(
            <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" #{"data-toggle=\"tooltip\" data-placement=\"#{is_inline ? 'bottom' : 'left'}\"" if only_icon} class="icon #{item_class} #{target_action.key}_#{scope}_link">
              <a class="nav-link #{extra_item_class} #{'active' if current_action?(target_action)} #{target_action.remote? ? 'ajax' : ''}" href="#{radmin.url_for(action: target_action.action_name, controller: 'radmin/main', model_name: abstract_model&.to_param, id: object&.id)}" #{"data-confirm=\"#{target_action.link_confirm_msg}\"" if target_action.link_confirm_msg.presence}>
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
    
    # def form_header
    #   model_label = current_model.label
    #   if @object.new_record?
    #     I18n.t('admin.form.new_model', name: model_label)
    #   else
    #     @object.send(current_model.object_label_method).presence || "#{model_label} ##{@object.id}"
    #   end  
    # end
  end
end