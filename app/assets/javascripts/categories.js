$(document).ready(function() {
  bindCategoryEvents();
});

function bindCategoryEvents() {
  $('.category').unbind();
  jQuery('.category').droppable({
    drop: function(ev, ui) {
      var droppedOn = jQuery(this);
      jQuery.ajax({
        type: 'PUT',
        url: '/admin/categories/' + encodeURIComponent(jQuery(ui.draggable).attr('data-id')) + '.js',
        data: { category: { parent_id: $(this).attr('data-id') } }
      });
    },
    hoverClass: 'hovering'
  });
  $('.category_root .category').droppable('option', 'greedy', true);

  $('.category_name').draggable({
    revert: 'invalid',
    opacity: 0.7,
    zIndex: 10000,
    helper: function(event) {
      return $('<div class="category">' + $(this).text() + '</div>');
    }
  });

  $('.disclosure').unbind();
  $('.disclosure').click(function(e) {
    var categoryId = $(this).attr('data-id');
    expandDisclosure(categoryId);
  });
}

function expandDisclosure(categoryId) {
  var disclosure = $('#disclosure_' + categoryId);
  if (disclosure.is('.collapsed')) {
    disclosure.removeClass('collapsed');
    disclosure.removeClass('expanded');
    disclosure.addClass('loading');
    $.get(
      '/admin/categories.js',
      { parent_id: categoryId },
      function(data) {
        disclosure.removeClass('loading');
        disclosure.addClass('expanded');
        bindCategoryEvents();
      }
    );
  }
  else {
    disclosure.removeClass('expanded');
    disclosure.addClass('collapsed');
    $('#category_' + categoryId + "_children").html('');
  }
}
