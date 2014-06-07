/*
 *= require jquery
 *= require jquery_ujs
 *= require jquery.ui.all
 *= require jquery.jeditable
 *= require bootstrap
 *= require bootstrap-datepicker/core
 *= require_self
*/
function autoComplete(model, attribute, path) {
  jQuery('#' + attribute + '_auto_complete').autocomplete({
    delay: 200,
    minLength: 3,
    source: function(request, response) {
      jQuery.getJSON(path, { name: request.term }, response);
    },
    messages: {
      noResults: null,
      results: function() {}
    },
    focus: function(event, ui) {
      jQuery('#promoter_auto_complete').val(ui.item.first_name + ' ' + ui.item.last_name);
      return false;
    },
    select: function(event, ui) {
      jQuery('#promoter_auto_complete').val(ui.item.first_name + ' ' + ui.item.last_name);
      jQuery('#event_promoter_id').val(ui.item.id);
      jQuery('#event_promoter_id').change();
      return false;
    }
  })
  .data("ui-autocomplete")
  ._renderItem = function(ul, item) {
      var description = [];
      if (item !== undefined && item.name !== undefined) {
        description.push(item.name);
      }
      if (item.city !== undefined) {
        description.push(item.city);
      }
      if (item.state !== undefined) {
        description.push(item.state);
      }

      return jQuery('<li id="person_' + item.id + '"></li>')
        .data( "item.autocomplete", item )
        .append('<a>' + item.first_name + ' ' + item.last_name + '<div class="informal">' + description + "</div></a>")
        .appendTo( ul );
    };
  ;
}

function autoCompleteTeam(model, attribute, path) {
  jQuery(document).ready(function() {
    jQuery('#' + attribute + '_auto_complete').autocomplete({
      delay: 200,
      minLength: 3,
      source: function(request, response) {
        jQuery.getJSON(path, { name: request.term }, response);
      },
      messages: {
        noResults: null,
        results: function() {}
      },
      focus: function(event, ui) {
        jQuery('#team_auto_complete').val(ui.item.name);
        return false;
      },
      select: function(event, ui) {
        jQuery('#team_auto_complete').val(ui.item.name);
        jQuery('#event_team_id').val(ui.item.id);
        return false;
      }
    })
    .data("ui-autocomplete")
    ._renderItem = function(ul, item) {
        return jQuery('<li id="team_' + item.id + '"></li>')
          .data( "item.autocomplete", item )
          .append('<a>' + item.name + '</a>')
          .appendTo( ul );
      };
    ;
  });
}

function makeEditable() {
  jQuery('.editable').editable(
    function(value, settings) {
      var element = jQuery(this);
      element.find("input").attr("disabled", "disabled");
      element.addClass('saving');
      var ajaxoptions = {
        type    : 'POST',
        data    : {
          '_method': 'PATCH',
          name: element.data('attribute'),
          value: value
        },
        dataType: 'html',
        url     : element.data('url'),
        success : function(result, status, jqXHR) {
          if (jqXHR.getResponseHeader('Content-Type').indexOf('text/javascript') == -1) {
            element.html(result);
            element.removeClass('saving');
            if (!jQuery.trim(element.html())) {
              element.html(settings.placeholder);
            }
          }
          else {
            element.removeClass('saving');
            jQuery.globalEval(result);
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
      jQuery.ajax(ajaxoptions);
    },
    {
      cssclass: 'editor_field',
      method: 'POST',
      placeholder: '',
      select: true,
      onblur: 'ignore',
      onedit: function() {
        jQuery(this).addClass('editing');
        return true;
      },
      onreset: function() {
        jQuery(this).closest('.editing').removeClass('editing');
        return true;
      },
      callback: function(value, settings) {
        jQuery(this).closest('.editing').removeClass('editing');
        return true;
      }
    }
  );
}

jQuery(document).ready(function() {
  makeEditable();
  jQuery('.wants_focus:visible').select();
});
