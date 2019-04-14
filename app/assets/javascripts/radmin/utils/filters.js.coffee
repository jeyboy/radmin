#= require 'radmin/utils/custom_filters'
#= require 'radmin/utils/inputs'

window.template_datetime = (name_mask, opts)->

window.template_time = (name_mask, opts)->

window.template_date = (name_mask, opts)->

window.template_integer = (name_mask, opts)->
  "<input type='number' name='#{name_mask}[v]' step='1'>"

window.template_float = (name_mask, opts)->
  "<input type='number' name='#{name_mask}[v]' step='0.01'>"

window.template_string = (name_mask, opts)->
  "<input type='text' name='#{name_mask}[v]'>"


$(document).ready ->
  $filters = $('#filters_box')

  if $filters.length
    input_num = 0

    proc_opt_selection = ($elem)->
      $option = $elem.find('option:selected')
      $parent = $elem.parent()
      $values_section = $parent.find('.values')

      val = $option.val()
      name_mask = $parent.data('mask')
      opts = $option.data()

      if Number(opts.count) > 0
        template = window["template_#{opts.type}"](name_mask);

        $values_section.html(template)

        init_select($values_section.find('select'))
      else
        $values_section.html('')


    show_separator = (show) ->
      $separator = $filters.next();

      if $separator.hasClass('filters_box')
        $separator.css({display: if show then 'block' else 'none'})


    build_template = (field_data) ->
      ++input_num

      mask = "f[#{field_data.name}][#{input_num}]"

      """
        <p class="filter" data-mask=#{mask}>
          <a class="remove_list_filter" href="#">
            <span class="filter_label">
              <i type="solid"></i>
              #{field_data.label || field_data.name}
            </span>
          </a>

          <select class="filter_args" name="#{mask}[o]" data-style="filter_select_style">
            #{build_options(field_data)}
          </select>

          <span class="values"></span>
        </p>
      """


    build_options = (field_data) ->
      opts = build_custom_options(field_data)

      return opts if opts

      opts = """
        <option val="_skip">...</option>
        <option value="_present">#{I18n.is_present}</option>
        <option value="_blank">#{I18n.is_blank}</option>
        <option data-divider="true"></option>
      """

      opts += switch field_data.type
        when 'boolean'
          """
            <option value="_true">#{I18n.true}</option>
            <option value="_false">#{I18n.false}</option>
          """
        when 'integer', 'float', 'decimal'
          input_type = field_data['input_type'] ||
            (if field_data.type == 'float' then 'float' else 'integer')

          """
            <option value="_exactly" data-count="1" data-type="#{input_type}>#{I18n.is_exactly}</option>
            <option value="_less" data-count="1" data-type="#{input_type}>#{I18n.is_less}</option>
            <option value="_bigger" data-count="1" data-type="#{input_type}>#{I18n.is_bigger}</option>
            <option value="_between_x_and_y" data-count="2" data-type="#{input_type}>#{I18n.between_x_and_y}</option>
          """
        when 'datetime', 'timestamp', 'date'
          input_type = field_data['input_type'] ||
            (if field_data.type == 'date' then 'date' else 'datetime')

          """
            <option value="_today">#{I18n.today}</option>
            <option value="_yesterday">#{I18n.yesterday}</option>
            <option value="_this_week">#{I18n.this_week}</option>
            <option value="_last_week">#{I18n.last_week}</option>

            <option data-divider="true"></option>
            <option value="_exactly" data-count="1" data-type="#{input_type}">#{I18n.is_exactly}</option>
            <option value="_less" data-count="1" data-type="#{input_type}">#{I18n.is_less}</option>
            <option value="_bigger" data-count="1" data-type="#{input_type}">#{I18n.is_bigger}</option>
            <option value="_between_x_and_y" data-count="2" data-type="#{input_type}">#{I18n.between_x_and_y}</option>
          """
        when 'enum', 'belongs_to_association' # finish me
#          input_type = field_data['input_type'] || 'string'

          """
            <option value="_present">#{I18n.is_present}</option>
          """

        when 'string', 'text'
          input_type = field_data['input_type'] || 'string'

          """
            <option value="_exactly" data-count="1" data-type="#{input_type}">#{I18n.is_exactly}</option>
            <option value="_contains" data-count="1" data-type="#{input_type}">#{I18n.contains}</option>
            <option value="_starts_with" data-count="1" data-type="#{input_type}">#{I18n.starts_with}</option>
            <option value="_ends_with" data-count="1" data-type="#{input_type}">#{I18n.ends_with}</option>
          """
        else
          input_type = field_data['input_type'] || 'string'

          """
            <option value="_exactly" data-count="1" data-type="#{input_type}>#{I18n.is_exactly}</option>
          """


    add_filter = (field_data) ->
      template = build_template(field_data)

      $template = $(template);

      init_select($template.find('select'))

      $filters.append($template)

      # init with values
#      if field_data.op


      show_separator(true)

    $('#list')
      .on 'changed.bs.select', '.filter_args.bootstrap-select', (e)->
        e.preventDefault();

        proc_opt_selection($(this))

        return

      .on 'click', '.list_filter', (e)->
        e.preventDefault();

        add_filter($(this).data())

        return

      .on 'click', '.remove_list_filter', (e)->
        e.preventDefault();

        $(this).closest('.filter').remove()

        unless $filters.has('.filter').length
          show_separator(false)

        return