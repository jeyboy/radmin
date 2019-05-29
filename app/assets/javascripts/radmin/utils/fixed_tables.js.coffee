#= require 'jquery-data-tables.min'
#= require 'jquery-data-tables-fixed-columns.min'
# require 'jquery-data-tables-fixed-header.min'
# require 'jquery-data-tables-keys.min'
# require 'jquery-data-tables-responsive.min'
# require 'jquery-data-tables-row-group.min'
# require 'jquery-data-tables-select.min'
# require 'jquery-data-tables-scroller.min'
# require 'jquery-data-tables-bootstrap4.min'

$('.data-fixed-table').DataTable(
#    scroller:       true
#    scrollY:        true
    scrollX:        true
#    scrollCollapse: true

#    keys:           true

#    select:         true
#    rowGroup:       true
#    responsive:     true
#    scroller:       true
    searching:      false
    paging:         false
#    fixedHeader:
#      header: true
##      headerOffset: 100
#      footer: false
##      footerOffset: 100

#    responsive: true,
    fixedColumns:
      leftColumns: 1
      rightColumns: 1
)