$(document).ready(function() {
  bindNumberYearChange();
});

function bindNumberYearChange() {
  $('#number_year').change(function() {
    $('#numbers_wrapper').load(
      '/admin/people/' + $('#number_year').attr('data-person-id') + '/number_year_changed',
      { year: $('#number_year').val() },
      function() {
        bindNumberYearChange();
      }
    );
  });  
}