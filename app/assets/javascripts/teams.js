jQuery(document).ready(function() {
  bindTeamDragAndDrop();
});

function bindTeamDragAndDrop() {
  jQuery('.team_icon').draggable({ 
    revert: 'invalid', 
    zIndex: 10000,
    opacity: 0.7,
    helper: function(event) {
      return jQuery('<div class="team" data-id="' + jQuery(this).attr('data-id') + '"><span class="glyphicon glyphicon-group"></span> ' + jQuery(this).attr('data-name') + '</div>');
    }
    });
  jQuery('.team_row').droppable({
    hoverClass: 'hovering',
    drop: function(event, ui) {
      ui.helper.hide('scale');
      ui.draggable.closest('tr').hide('fade');
      jQuery(this).addClass('merging');
      jQuery.ajax({
        url: '/admin/teams/' + jQuery(this).attr('data-id') + '/merge/' + ui.draggable.attr('data-id') +'.js',
        type: 'POST',
        dataType: 'script'
      });
    }
  });
}