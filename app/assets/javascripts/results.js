// TODO Consolidate this and toggle_member with makeEditable()
function bindBarCheckBox() {
  jQuery('.bar_check_box').change(function(e) {
    var ajaxoptions = {
      type    : 'PUT',
      data    : {
        '_method': 'PUT',
        name: 'bar'
      },
      url     : jQuery(this).data('url')
    };
    if (e.target.checked) {
      ajaxoptions.data['value'] = '1';
    }
    else {
      ajaxoptions.data['value'] = '0';
    }
    jQuery.ajax(ajaxoptions);
  }); 
}

jQuery(document).ready(function() {
  bindBarCheckBox();
});
