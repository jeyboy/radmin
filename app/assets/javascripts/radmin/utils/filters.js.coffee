#= require 'radmin/utils/custom_filters'
#= require 'radmin/utils/selects'

$(document).ready ->
  $filters = $('#filters_box')

  if $filters.length
    input_num = 0

#    @select_custom_option = (option, field_data)->
      #  return null

    select_option = (inputs_map, field_data, input_sequence_num)->


    proc_opt_selection = ($elem)->
      val = $elem.find('option:selected').val()


#      switch val
##        when "_skip"
##        when "_true"
##        when "_false"
##        when "_today"
##        when "_yesterday"
##        when "_this_week"
##        when "_last_week"
#
#        when "_present"
#
#        when "_blank"
#
#        when "_exactly"
#
#        when "_less"
#
#        when "_bigger"
#
#        when "_between_x_and_y"
#
#        when "_exactly"
#
#        when "_contains"
#
#        when "_starts_with"
#
#        when "_ends_with"
#
#        else


    show_separator = (show) ->
      $separator = $filters.next();

      if $separator.hasClass('filters_box')
        $separator.css({display: if show then 'block' else 'none'})


    build_template = (field_data) ->
      """
        <p class="filter" data-type="#{field_data.type}" data-num=#{++input_num}>
          <a class="remove_list_filter" href="#">
            <span class="filter_label">
              <i type="solid"></i>
              #{field_data.name}
            </span>
          </a>

          <select class="filter_args" name="f[#{input_num}][o]" data-style="filter_select_style">
            #{build_options(field_data)}
          </select>
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
          """
            <option value="_exactly">#{I18n.is_exactly}</option>
            <option value="_less">#{I18n.is_less}</option>
            <option value="_bigger">#{I18n.is_bigger}</option>
            <option value="_between_x_and_y">#{I18n.between_x_and_y}</option>
          """
        when 'datetime', 'timestamp', 'date'
          """
            <option value="_today">#{I18n.today}</option>
            <option value="_yesterday">#{I18n.yesterday}</option>
            <option value="_this_week">#{I18n.this_week}</option>
            <option value="_last_week">#{I18n.last_week}</option>

            <option data-divider="true"></option>
            <option value="_exactly">#{I18n.is_exactly}</option>
            <option value="_less">#{I18n.is_less}</option>
            <option value="_bigger">#{I18n.is_bigger}</option>
            <option value="_between_x_and_y">#{I18n.between_x_and_y}</option>
          """
        when 'enum' # finish me
          """
            <option value="_present">#{I18n.is_present}</option>
          """

        when 'string', 'text', 'belongs_to_association'
          """
            <option value="_exactly">#{I18n.is_exactly}</option>
            <option value="_contains">#{I18n.contains}</option>
            <option value="_starts_with">#{I18n.starts_with}</option>
            <option value="_ends_with">#{I18n.ends_with}</option>
          """
        else
          """
            <option value="_exactly">#{I18n.is_exactly}</option>
          """

    $('#list')
      .on 'changed.bs.select', '.filter_args.bootstrap-select', (e)->
        e.preventDefault();

        proc_opt_selection($(this))

        return

      .on 'click', '.list_filter', (e)->
        e.preventDefault();

        template = build_template($(this).data())

        $template = $(template);

        init_select($template.find('select'))

        $filters.append($template)

        show_separator(true)

        return

      .on 'click', '.remove_list_filter', (e)->
        e.preventDefault();

        $(this).closest('.filter').remove()

        unless $filters.has('.filter').length
          show_separator(false)

        return