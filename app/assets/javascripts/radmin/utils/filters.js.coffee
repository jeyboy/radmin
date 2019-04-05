#= require 'radmin/utils/custom_filters'

$(document).ready ->
  build_options = (field_type)->
    switch field_type
      when 'boolean'
        """
          <option>...<option>
          <option value="_true">#{I18n.true}<option>
          <option value="_false">#{I18n.false}<option>
          <option data-divider="true"><option>
          <option value="_present">#{I18n.is_present}<option>
          <option value="_blank">#{I18n.is_blank}<option>
        """
      when 'integer', 'float', 'decimal'
        """
          <option>...<option>
          <option value="_exactly">#{I18n.is_exactly}<option>
          <option value="_less">#{I18n.is_less}<option>
          <option value="_bigger">#{I18n.is_bigger}<option>
          <option data-divider="true"><option>
          <option value="_present">#{I18n.is_present}<option>
          <option value="_blank">#{I18n.is_blank}<option>
        """
      else
        """
          <option>...<option>
        """

  filter_template = ->
    ""
    
  
  $('#list')
    .on 'click', '.list_filter', ->


      return
      
    .on 'click', '.remove_list_filter', ->
      return