// TODO Consolidate this and toggle_member with makeEditable()
function bindBarCheckBox() {
  $('.bar_check_box').change(function(e) {
    var ajaxoptions = {
      type    : 'PUT',
      data    : {
        '_method': 'PUT',
        name: 'bar'
      },
      url     : $(this).data('url')
    };
    if (e.target.checked) {
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
