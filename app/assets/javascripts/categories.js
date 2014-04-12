jQuery(document).ready(function() {
  bindCategoryEvents();
});

function bindCategoryEvents() {
  jQuery('.category').unbind();
  jQuery('.category').droppable({
    drop: function(ev, ui) {
      var droppedOn = jQuery(this);
      jQuery.ajax({
        type: 'PATCH',
        url: '/admin/categories/' + encodeURIComponent(jQuery(ui.draggable).attr('data-id')) + '.js',
        data: { category: { parent_id: jQuery(this).attr('data-id') } }
      });
    },
    hoverClass: 'hovering'
  });
  jQuery('.category_root .category').droppable('option', 'greedy', true);

  jQuery('.category_name').draggable({
    revert: 'invalid',
    opacity: 0.7,
    zIndex: 10000,
    helper: function(event) {
      return jQuery('<div class="category"><span class="glyphicon glyphicon-star"></span>' + jQuery(this).text() + '</div>');
    }
  });

  jQuery('.disclosure').unbind();
  jQuery('.disclosure').click(function(e) {
    var categoryId = jQuery(this).attr('data-id');
    expandDisclosure(categoryId);
  });
}

function expandDisclosure(categoryId) {
  var disclosure = jQuery('#disclosure_' + categoryId);
  if (disclosure.is('.collapsed')) {
    disclosure.removeClass('collapsed');
    disclosure.removeClass('expanded');
    disclosure.addClass('icon-refresh');
    disclosure.addClass('rotate');

    jQuery.get(
      '/admin/categories.js',
      { parent_id: categoryId },
      function(data) {
        disclosure.removeClass('icon-refresh');
        disclosure.removeClass('rotate');
        disclosure.addClass('expanded');
        bindCategoryEvents();
      }
    );
  }
  else {
    disclosure.removeClass('expanded');
    disclosure.addClass('collapsed');
    jQuery('#category_' + categoryId + "_children").html('');
  }
}
