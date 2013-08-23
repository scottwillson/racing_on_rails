jQuery(document).ready(function() {
  bindDestroyNumber();
  bindPeopleDragAndDrop();
  bindNumberYearChange();
  bindExport();
});

function bindNumberYearChange() {
  jQuery('#number_year').change(function() {
    jQuery.ajax({
      url: '/admin/people/number_year_changed.js',
      data: { 
        year: jQuery('#number_year').val(),
        id: jQuery('#number_year').attr('data-person-id')
      },
      type: 'post'
    });
  });  
}

function bindPeopleDragAndDrop() {
  jQuery('.person_icon').draggable({ 
    revert: 'invalid', 
    zIndex: 10000,
    opacity: 0.7,
    helper: function(event) {
      return jQuery('<div class="person" data-id="' + jQuery(this).attr('data-id') + '"><i class="icon-user"></i> ' + jQuery(this).attr('data-name') + '</div>');
    }
    });
  jQuery('.person_row').droppable({
    hoverClass: 'hovering',
    drop: function(event, ui) {
      ui.helper.hide('scale');
      ui.draggable.closest('tr').hide('fade');
      jQuery(this).addClass('merging');
      jQuery.ajax({
        url: '/admin/people/' + jQuery(this).attr('data-id') + '/merge/' + ui.draggable.attr('data-id') +'.js',
        type: 'POST',
        dataType: 'script'
      });
    }
  });
}

function bindDestroyNumber() {
  jQuery('a.destroy_number').click(function() {
    jQuery('#new_number_' + jQuery(this).attr('data-row-id')).remove();
    return false;
  });
}

function bindExport() {
  jQuery('#export_button').click(function() {
    submit_export(this);
    return false;
  });
}

function submit_export() {
  if (jQuery('#format').val() == 'scoring_sheet') {
    this.location = '/admin/people.xls?excel_layout=scoring_sheet&include=' + jQuery('#include').val();
  }
  else {
    this.location = '/admin/people.' + jQuery('#format').val() + '?excel_layout=' + jQuery('#format').val() + '&include=' + jQuery('#include').val();
  }
}
