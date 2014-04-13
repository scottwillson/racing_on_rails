jQuery(document).ready(function() {
  jQuery('#upload_form').change(function () {
    jQuery('#upload_form_label').hide();
    jQuery('#upload_form').hide();
    jQuery('#upload_progress').show();
    jQuery('#upload_form').submit();
    jQuery('#event_type').tooltip();
  });

  jQuery('#propagate_races').bind('ajax:beforeSend', function() {
    jQuery('#propagate_races').hide();
    jQuery('#propagate_races_progress').show();
  });

  jQuery('#destroy_races').bind('ajax:beforeSend', function() {
    jQuery('#destroy_races').hide();
    jQuery('#destroy_races_progress').show();
  });

  jQuery('#edit_promoter_link').click(function() {
    window.location.href = '/admin/people/' + jQuery('#event_promoter_id').val() + '/edit?event_id=' + jQuery('#edit_promoter_link').attr('data-event-id');
    return false;
  });
    //
  jQuery('[data-behaviour~=datepicker]').datepicker(
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
