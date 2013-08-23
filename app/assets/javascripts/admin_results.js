$(document).ready(function() {
  $('#find_person_form').submit(function() {
    $('#find_progress_icon').show();
    jQuery.ajax(
      { complete: function(request) {
                    $(document).scrollTop(0); 
                    $('#right_person').show(); 
                    $('#find_progress_icon').hide();
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
  var id = /\d+/.exec($(element).attr('id'))[0];
  if ($(element).is('.collapsed')) {
    $(element).removeClass('collapsed');
    $(element).removeClass('expanded');
    $(element).addClass('icon-refresh');
    $(element).addClass('rotate');
    $.ajax({
      url: '/admin/results/' + id + '/scores',
      type: 'post',
      dataType: 'script',
      complete: function() {
        expand(element);          
      }
    });
  }
  else {
    $(element).addClass('collapsed');
    $(element).removeClass('expanded');
    $(element).removeClass('icon-refresh');
    $(element).removeClass('rotate');
    $('tr.scores_' + id).each(function(index, e) {
      $(e).remove();
    });
  }
}

function expand(element) {
  $(element).removeClass('collapsed');
  $(element).addClass('expanded');
  $(element).removeClass('icon-refresh');
  $(element).removeClass('rotate');
}
