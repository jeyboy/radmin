#= require 'radmin/utils/custom_filters'

$(document).ready ->
  build_template = ()->
    """
      <p class="filter">
      <span class="filter_label">
      <a href="#"><i type="solid" class="fa fa-trash"></i>
      Cool
      </a></span>
      <input>
      <input>
      </p>
    """


  build_options = (field_data)->
    opts = build_custom_options(field_data)

    return opts if opts

    opts = """
      <option>...<option>
      <option value="_present">#{I18n.is_present}<option>
      <option value="_blank">#{I18n.is_blank}<option>
      <option data-divider="true"><option>
    """

    opts += switch field_data.type
      when 'boolean'
        """
          <option value="_true">#{I18n.true}<option>
          <option value="_false">#{I18n.false}<option>
        """
      when 'integer', 'float', 'decimal'
        """
          <option value="_exactly">#{I18n.is_exactly}<option>
          <option value="_less">#{I18n.is_less}<option>
          <option value="_bigger">#{I18n.is_bigger}<option>
          <option value="_between_x_and_y">#{I18n.between_x_and_y}<option>
        """
      when 'date'
        """
          <option value="_today">#{I18n.today}<option>
          <option value="_yesterday">#{I18n.yesterday}<option>
          <option value="_this_week">#{I18n.this_week}<option>
          <option value="_last_week">#{I18n.last_week}<option>

          <option data-divider="true"><option>
          <option value="_exactly">#{I18n.is_exactly}<option>
          <option value="_less">#{I18n.is_less}<option>
          <option value="_bigger">#{I18n.is_bigger}<option>
          <option value="_between_x_and_y">#{I18n.between_x_and_y}<option>
        """
      when 'datetime', 'timestamp'
        """
          <option value="_today">#{I18n.today}<option>
          <option value="_yesterday">#{I18n.yesterday}<option>
          <option value="_this_week">#{I18n.this_week}<option>
          <option value="_last_week">#{I18n.last_week}<option>

          <option data-divider="true"><option>
          <option value="_exactly">#{I18n.is_exactly}<option>
          <option value="_less">#{I18n.is_less}<option>
          <option value="_bigger">#{I18n.is_bigger}<option>
          <option value="_between_x_and_y">#{I18n.between_x_and_y}<option>
        """
      when 'enum' # finish me
        """
          <option>...<option>
          <option value="_present">#{I18n.is_present}<option>
          <option value="_blank">#{I18n.is_blank}<option>
          <option data-divider="true"><option>
        """

      when 'string', 'text', 'belongs_to_association'
        """
          <option value="_exactly">#{I18n.is_exactly}<option>
          <option value="_contains">#{I18n.contains}<option>
          <option value="_starts_with">#{I18n.starts_with}<option>
          <option value="_ends_with">#{I18n.ends_with}<option>
        """
      else
        """
          <option value="_exactly">#{I18n.is_exactly}<option>
        """

  
  $('#list')
    .on 'click', '.list_filter', ->


      return
      
    .on 'click', '.remove_list_filter', ->
      return