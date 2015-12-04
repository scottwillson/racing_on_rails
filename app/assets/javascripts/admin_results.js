jQuery(document).ready(function() {
  jQuery('#find_person_form').submit(function() {
    jQuery('#find_progress_icon').show();
    jQuery.ajax(
      { complete: function() {
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
  if (jQuery(element).is('.glyphicon-collapse')) {
    jQuery(element).removeClass('glyphicon-collapse');
    jQuery(element).removeClass('glyphicon-expand');
    jQuery(element).addClass('glyphicon-refresh');
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
    jQuery(element).addClass('glyphicon-collapse');
    jQuery(element).removeClass('glyphicon-expand');
    jQuery(element).removeClass('glyphicon-refresh');
    jQuery(element).removeClass('rotate');
    jQuery('tr.scores_' + id).each(function(index, e) {
      jQuery(e).remove();
    });
  }
}

function expand(element) {
  jQuery(element).removeClass('glyphicon-collapse');
  jQuery(element).addClass('glyphicon-expand');
  jQuery(element).removeClass('glyphicon-refresh');
  jQuery(element).removeClass('rotate');
}
