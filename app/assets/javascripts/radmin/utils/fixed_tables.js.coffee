#= require 'jquery-data-tables.min'
#= require 'jquery-data-tables-fixed-columns.min'
#= require 'jquery-data-tables-fixed-header.min'
#= require 'jquery-data-tables-bootstrap4.min'

$('.data-fixed-table').DataTable(
    scrollY:        true,
    scrollX:        true,
    scrollCollapse: true,
    paging:         false,
    fixedHeader: true,
#    keys: true,
#    responsive: true,
    fixedColumns:
      leftColumns: 1,
      rightColumns: 1
)