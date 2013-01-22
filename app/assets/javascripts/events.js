$(document).ready(function() {
  $('#upload_form').change(function () {
    $('#upload_form_label').hide(); 
    $('#upload_form').hide(); 
    $('#upload_progress').show(); 
    $('#upload_form').submit();
  });
  
  $('#propagate_races').bind('ajax:beforeSend', function() {
    $('#propagate_races').hide();
    $('#propagate_races_progress').show();
  });
  
  $('#destroy_races').bind('ajax:beforeSend', function() {
    $('#destroy_races').hide();
    $('#destroy_races_progress').show();
  });
  
  $('#edit_promoter_link').click(function() {
    window.location.href = '/admin/people/' + $('#event_promoter_id').val() + '/edit?event_id=' + $('#edit_promoter_link').attr('data-event-id'); 
    return false;
  });
});
