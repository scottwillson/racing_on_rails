$(document).ready(function() {
  bindDragAndDrop();
});

function bindDragAndDrop() {
  $('.team_icon').draggable({ 
    revert: 'invalid', 
    zIndex: 10000,
    opacity: 0.7,
    helper: function(event) {
      return $('<div class="team" data-id="' + $(this).attr('data-id') + '">' + $(this).attr('data-name') + '</div>');
    }
    });
  $('.team_row').droppable({
    hoverClass: 'hovering',
    drop: function(event, ui) {
      ui.helper.hide('scale');
      ui.draggable.closest('tr').hide('fade');
      $(this).addClass('merging');
      $.ajax({
        url: '/admin/teams/' + $(this).attr('data-id') + '/merge/' + ui.draggable.attr('data-id') +'.js',
        type: 'POST',
        dataType: 'script'
      });
    }
  });
}