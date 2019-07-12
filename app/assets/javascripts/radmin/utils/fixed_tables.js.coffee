#= require 'radmin/utils/jquery-jtables'

#$('.data-fixed-table').DataTable(
##  scroller:       true
#  scrollY:        true
#  scrollX:        true
#  scrollCollapse: true
#
##    keys:           true
#
##    select:         true
##    rowGroup:       true
##    responsive:     true
#  searching:      false
#  paging:         false
#  fixedHeader:
#    header: true
#    headerOffset: 100
##    footer: false
##    footerOffset: 100
#
##    responsive: true,
#  fixedColumns:
#    leftColumns: 1
#    rightColumns: 1
#)

$('.data-fixed-table').jtable({
  fixedLeftColumns: 1,
  fixedRightColumns: 1
})