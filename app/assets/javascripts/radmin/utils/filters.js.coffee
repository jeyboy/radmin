#= require 'radmin/utils/custom_filters'
#= require 'radmin/utils/inputs'

window.template_datetime = (name_mask, opts)->

window.template_time = (name_mask, opts)->

window.template_date = (name_mask, opts)->

window.template_integer = (name_mask, opts)->
  "<input type='number' value='#{opts && opts.v || ''}' name='#{name_mask}[v]' step='1'>"

window.template_float = (name_mask, opts)->
  "<input type='number' value='#{opts && opts.v || ''}' name='#{name_mask}[v]' step='0.01'>"

window.template_string = (name_mask, opts)->
  "<input type='text' value='#{opts && opts.v || ''}' name='#{name_mask}[v]'>"


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

    intup_amount = Number(opts.count)

    if intup_amount > 0
      $parent_select = $elem.find('select')

      values = $parent_select.data('values')

      if values
        values_len = values.length
        template = ''

        for i in [0...intup_amount]
          val = if i < values_len then values[i] else ''
          template = template.concat(window["template_#{opts.type}"](name_mask, {v: val}))

        $parent_select.data('values', null)
      else
        template = window["template_#{opts.type}"](name_mask);
        template = template.repeat(intup_amount)

      $values_section.html(template.repeat(intup_amount))
      init_select($values_section.find('select'))
    else
      $values_section.html('')


  show_separator = (show) ->
    $separator = $filters.next();

    if $separator.hasClass('filters_box')
      $separator.css({display: if show then 'block' else 'none'})


  build_rels_template = (mask) ->
    """
      <select class="rel_args hide" name="#{mask}[r]" data-style="filter_rel_select_style">
        <option value='or' selected>OR</option>
        <option value='and'>AND</option>
      </select>
    """

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

        #{ if window.use_relations then build_rels_template(mask) else '' }
      </p>
    """


  build_options = (field_data) ->
    opts = build_custom_options(field_data)

    return opts if opts

    opts = """
      <option value="_skip">...</option>
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


  window.add_filter = (field_data, key, rel, values) ->
    template = build_template(field_data)

    $template = $(template)

    $selects = $template.find('select')

    init_select($selects)

    $last_filter = $filters.find('.filter:last-child')

    $filters.append($template)

    if (key)
      $filter_select = $selects.filter('.filter_args')

      $filter_select.data('values', values)

      $filter_select.val(key)
      $filter_select
        .selectpicker("refresh")
        .trigger('changed.bs.select')

      if (rel)
        $rel_select = $selects.filter('.rel_args')
        $rel_select.selectpicker('val', rel);


    show_separator(true)

    $last_filter.find('.rel_args').removeClass('hide')

    $template


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
      else
        $last_filter = $filters.find('.filter:last-child')
        $last_filter.find('.rel_args').addClass('hide')

      return
