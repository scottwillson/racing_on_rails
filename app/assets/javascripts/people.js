$(document).ready(function() {
  bindNumberYearChange();
  bindDragAndDrop();
});

function bindNumberYearChange() {
  $('#number_year').change(function() {
    $('#numbers_wrapper').load(
      '/admin/people/number_year_changed',
      { 
        year: $('#number_year').val(),
        id: $('#number_year').attr('data-person-id')
      },
      function() {
        bindNumberYearChange();
      }
    );
  });  
}

function bindDragAndDrop() {
  $('.person_icon').draggable({ 
    revert: 'invalid', 
    zIndex: 10000,
    opacity: 0.7,
    helper: function(event) {
      return $('<div class="person" data-id="' + $(this).attr('data-id') + '">' + $(this).attr('data-name') + '</div>');
    }
    });
  $('.person_row').droppable({
    hoverClass: 'hovering',
    drop: function(event, ui) {
      ui.helper.hide('scale');
      ui.draggable.closest('tr').hide('fade');
      $(this).addClass('merging');
      $.ajax({
        url: '/admin/people/' + $(this).attr('data-id') + '/merge/' + ui.draggable.attr('data-id') +'.js',
        type: 'POST',
        dataType: 'script'
      });
    }
  });
}