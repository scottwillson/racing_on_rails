$(document).ready(function() {
  $('#upload_form').change(function () {
    $('#upload_form_label').hide(); 
    $('#upload_form').hide(); 
    $('#upload_progress').show(); 
    $('#upload_form').submit();
  });
});
