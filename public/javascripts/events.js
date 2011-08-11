$(document).ready(function() {
  $('#upload_form').change(function () {
    $('#upload_form_label').hide(); 
    $('#upload_form').hide(); 
    $('#upload_progress').show(); 
    $('#upload_form').submit();
  });
  
  $('#propagate_races').live('ajax:beforeSend', function() {
    $('#propagate_races').hide();
    $('#propagate_races_progress').show();
  });
  
  $('#destroy_races').live('ajax:beforeSend', function() {
    $('#destroy_races').hide();
    $('#destroy_races_progress').show();
  });
});
