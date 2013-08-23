$(document).ready(function() {
  $('#upload_form').change(function () {
    $('#upload_form_label').hide(); 
    $('#upload_form').hide(); 
    $('#upload_progress').show(); 
    $('#upload_form').submit();
    $('#event_type').tooltip();
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
    // 
  $('[data-behaviour~=datepicker]').datepicker(
    { autoclose: true }
  ).on('changeDate', function(e) {
    var inputId = '#' + jQuery(this).data('target');
    var target = jQuery(inputId)[0];
    target.disabled = true;
    jQuery.get('/human_dates/' + e.date.getFullYear() + '-' + (e.date.getMonth() + 1) + '-' + e.date.getDate() + '.json', function(data) {
      target.value = data;
      target.disabled = false;
    });
    return false;
  });
});
