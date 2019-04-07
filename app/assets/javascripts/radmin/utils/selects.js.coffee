@default_preprocessor = (data)->
  console.log('preprocessData')
  console.log(data)

#        var contacts = [];
#        if(data.hasOwnProperty('Contacts')){
#          var len = data.Contacts.length;
#          for(var i = 0; i < len; i++){
#            var curr = data.Contacts[i];
#          contacts.push(
#            {
#              'value': curr.ContactID,
#              'text': curr.FirstName + ' ' + curr.LastName,
#              'data': {
#                'icon': 'icon-person',
#                'subtext': 'Internal'
#              },
#              'disabled': false
#            }
#          );
#          }
#        }
#        return contacts;

@init_select = ($elem, preprocessor)->
  $elem
    .selectpicker(
      liveSearch: true,
      iconBase: 'fa',
      showIcon: true,
      showSubtext: true,
      tickIcon: 'fa-check'
    )
    .ajaxSelectPicker(
      ajax:
        url: '/server/path/to/ajax/results',
        data:
          q: '{{{q}}}'

      locale:
        emptyTitle: 'Searching...'

      preprocessData: preprocessor || @default_preprocessor
      preserveSelected: false
    )


$(document).ready ->
  init_select($('.select'))
