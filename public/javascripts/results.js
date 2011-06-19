// TODO Consolidate this and toggle_member with makeEditable()
function bindBarCheckBox() {
  $('.bar_check_box').change(function(e) {
    console.log(e);
    var ajaxoptions = {
      type    : 'PUT',
      data    : {
        '_method': 'PUT',
        name: 'bar'
      },
      url     : $(this).data('url')
    };
    if (e.target.value == '0') {
      ajaxoptions.data['value'] = '1';      
    }
    else {
      ajaxoptions.data['value'] = '0';
    }
    $.ajax(ajaxoptions);
  }); 
}

$(document).ready(function() {
  bindBarCheckBox();
});
