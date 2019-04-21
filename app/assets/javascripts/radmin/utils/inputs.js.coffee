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
  remote_search = $elem.data('remote-search');
  live_search = $elem.data('live-search') || remote_search;

  $elem
    .selectpicker(
      liveSearch: !!live_search,
      iconBase: 'fa',
      showIcon: true,
      showSubtext: true,
      tickIcon: 'fa-check'
    )


  if remote_search
    $elem
      .ajaxSelectPicker(
        ajax:
          url: remote_search,
          data:
            q: '{{{q}}}'

        locale:
          emptyTitle: 'Searching...'

        preprocessData: preprocessor || @default_preprocessor
        preserveSelected: false
      )

init_select($('.select'))
