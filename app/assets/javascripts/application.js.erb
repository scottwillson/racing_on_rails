/*
 *= require jquery
 *= require jquery_ujs
 *= require jquery-ui
 *= require jquery.jeditable
 *= require_self
 *= require tabs
*/

function restripeTable(id) {
  var startIndex = 0;
  if ($('#' + id + ' tr th').length > 0) {
    startIndex = 1;
  }
  
  $('#' + id + ' tr').each(function(index, tr) {
    var row = $(tr);
    row.removeClass('merging');
    if (index >= startIndex && (row.hasClass('even') || row.hasClass('odd'))) {
      row.removeClass('even');
      row.removeClass('odd');
      if ((index + startIndex) % 2 == 0) {
        row.addClass('even');
      }
      else {
        row.addClass('odd');
      }
    }
  });
}

function flash(key, message) {
  hideFlash();
  $('#' + key + '_span').html(message);
  $('#' + key).show();
}

function hideFlash() {
  if ($('#info').length > 0) { $('#info').hide(); }
  if ($('#notice').length > 0) { $('#notice').hide(); }
  if ($('#warn').length > 0) { $('#warn').hide(); }
}

function autoComplete(model, attribute, path) {
  $(document).ready(function() {
    $('#' + attribute + '_auto_complete').autocomplete({
      delay: 200,
      minLength: 3,
      source: path,
      focus: function(event, ui) {
        $('#promoter_auto_complete').val(ui.item.person.first_name + ' ' + ui.item.person.last_name);
        return false;
      },
      select: function(event, ui) {
        $('#promoter_auto_complete').val(ui.item.person.first_name + ' ' + ui.item.person.last_name);
        $('#event_promoter_id').val(ui.item.person.id);
        $('#event_promoter_id').change();
        return false;
      }
    })
    .data("autocomplete")
    ._renderItem = function(ul, item) {
        var description = [];
        if (item.person.team !== undefined && item.person.team.name !== undefined) {
          description.push(item.person.team.name);
        }
        if (item.person.city !== undefined) {
          description.push(item.person.city);
        }
        if (item.person.state !== undefined) {
          description.push(item.person.state);
        }
        
        return $('<li id="person_' + item.person.id + '"></li>')
          .data( "item.autocomplete", item )
          .append('<a>' + item.person.first_name + ' ' + item.person.last_name + '<div class="informal">' + description + "</div></a>")
          .appendTo( ul );
      };
    ;
  });  
}    

function autoCompleteTeam(model, attribute, path) {
  $(document).ready(function() {
    $('#' + attribute + '_auto_complete').autocomplete({
      delay: 200,
      minLength: 3,
      source: path,
      focus: function(event, ui) {
        $('#team_auto_complete').val(ui.item.team.name);
        return false;
      },
      select: function(event, ui) {
        $('#team_auto_complete').val(ui.item.team.name);
        $('#event_team_id').val(ui.item.team.id);
        return false;
      }
    })
    .data("autocomplete")
    ._renderItem = function(ul, item) {
        return $('<li id="team_' + item.team.id + '"></li>')
          .data( "item.autocomplete", item )
          .append('<a>' + item.team.name + '</a>')
          .appendTo( ul );
      };
    ;
  });  
}    

function makeEditable() {
  $('.editable').editable(
    function(value, settings) {
      var element = $(this);
      element.addClass('saving');
      var ajaxoptions = {
        type    : 'PUT',
        data    : {
          '_method': 'PUT',
          name: element.data('attribute'),
          value: value            
        },
        dataType: 'html',
        url     : element.data('url'),
        success : function(result, status, jqXHR) {
          if (jqXHR.getResponseHeader('Content-Type').indexOf('text/javascript') == -1) {
            element.html(result);
            element.removeClass('saving');
            if (!$.trim(element.html())) {
              element.html(settings.placeholder);
            }
          }
          else {
            element.removeClass('saving');
            $.globalEval(result);
          }
        },
        error   : function(xhr, status, error) {
          element.removeClass('saving');
          var originalColor = element.css('background-color');
          element.css({ 'background-color': 'rgb(255, 204, 204)' });
          element.animate({ 'background-color': originalColor }, 2000);
          element.html(element.data('original'));
        }
      };
      element.find("input").attr("disabled", "disabled");
      $.ajax(ajaxoptions);
    },
    {
      cssclass: 'editor_field',
      method: 'PUT',
      placeholder: '',
      select: true,
      onblur: 'ignore'
    }
  );
}

$(document).ready(function() {
  $('.wants_focus:visible').select();
  makeEditable();
});
