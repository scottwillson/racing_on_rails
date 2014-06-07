jQuery(document).ready(function() {
  bindCategoryEvents();
});

function bindCategoryEvents() {
  jQuery('.category').unbind();
  jQuery('.category').droppable({
    drop: function(ev, ui) {
      var droppedOn = jQuery(this);
      jQuery.ajax({
        type: 'POST',
        url: '/admin/categories/' + encodeURIComponent(jQuery(ui.draggable).attr('data-id')) + '.js',
        data: { '_method': 'PATCH', category: { parent_id: jQuery(this).attr('data-id') } }
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
  if (disclosure.is('.glyphicon-collapse')) {
    disclosure.removeClass('glyphicon-collapse');
    disclosure.removeClass('glyphicon-expand');
    disclosure.addClass('glyphicon-refresh');
    disclosure.addClass('rotate');

    jQuery.get(
      '/admin/categories.js',
      { parent_id: categoryId },
      function(data) {
        disclosure.removeClass('glyphicon-refresh');
        disclosure.removeClass('rotate');
        disclosure.addClass('glyphicon-expand');
        bindCategoryEvents();
      }
    );
  }
  else {
    disclosure.removeClass('glyphicon-expand');
    disclosure.addClass('glyphicon-collapse');
    jQuery('#category_' + categoryId + "_children").html('');
  }
}
