jQuery(document).ready(function() {
  jQuery('#find_person_form').submit(function() {
    jQuery('#find_progress_icon').show();
    jQuery.ajax(
      { complete: function(request) {
                    jQuery(document).scrollTop(0); 
                    jQuery('#right_person').show(); 
                    jQuery('#find_progress_icon').hide();
                  }, 
        data: jQuery.param(jQuery(this).serializeArray()), 
        success: function(request) { 
          jQuery('#right_person').html(request);
        }, 
        type: 'post',
        url: '/admin/results/find_person?ignore_id=630815940'
      }
    ); 
    return false;
  });
});

function toggle_disclosure(element) {
  var id = /\d+/.exec(jQuery(element).attr('id'))[0];
  if (jQuery(element).is('.collapsed')) {
    jQuery(element).removeClass('collapsed');
    jQuery(element).removeClass('expanded');
    jQuery(element).addClass('icon-refresh');
    jQuery(element).addClass('rotate');
    jQuery.ajax({
      url: '/admin/results/' + id + '/scores',
      type: 'post',
      dataType: 'script',
      complete: function() {
        expand(element);          
      }
    });
  }
  else {
    jQuery(element).addClass('collapsed');
    jQuery(element).removeClass('expanded');
    jQuery(element).removeClass('icon-refresh');
    jQuery(element).removeClass('rotate');
    jQuery('tr.scores_' + id).each(function(index, e) {
      jQuery(e).remove();
    });
  }
}

function expand(element) {
  jQuery(element).removeClass('collapsed');
  jQuery(element).addClass('expanded');
  jQuery(element).removeClass('icon-refresh');
  jQuery(element).removeClass('rotate');
}
