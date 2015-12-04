/*
 *= require jquery
 *= require jquery_ujs
 *= require jquery-ui
 *= require jquery.jeditable
 *= require bootstrap
 *= require bootstrap-datepicker/core
 *= require raygun
 *= require_self
*/
function bindAutocomplete() {
  if (jQuery('.autocomplete').length) {
    jQuery('.autocomplete').autocomplete({
      delay: 200,
      minLength: 3,
      source: function(request, response) {
        jQuery.getJSON('/people.json', { name: request.term }, response);
      },
      messages: {
        noResults: null,
        results: function() {}
      },
      focus: function(event, ui) {
        jQuery(this).val(ui.item.first_name + ' ' + ui.item.last_name);
        return false;
      },
      select: function(event, ui) {
        jQuery(this).val(ui.item.first_name + ' ' + ui.item.last_name);
        var idField = jQuery('#' + jQuery(this).data('id-field'));
        idField.val(ui.item.id);
        idField.change();
        return false;
      }
    });

    $('.autocomplete').each(function() {
      $(this).data('uiAutocomplete')._renderItem = function (ul, item) {
        var description = [];
        if (item && item.team_name && item.team_name !== '') {
          description.push(item.team_name);
        }
        if (item.city && jQuery.trim(item.city) !== '') {
          description.push(jQuery.trim(item.city));
        }
        if (item.state && jQuery.trim(item.state) !== '') {
          description.push(jQuery.trim(item.state));
        }

        return jQuery('<li id="person_' + item.id + '"></li>')
          .data("item.autocomplete", item)
          .append('<a>' + item.name + '<div class="informal">' + description.join(', ') + "</div></a>")
          .appendTo(ul);
      };
    });
  }
}

function bindAutocompleteTeam() {
  if (jQuery('.team_autocomplete').length) {
    jQuery('.team_autocomplete').autocomplete({
      delay: 200,
      minLength: 3,
      source: function(request, response) {
        jQuery.getJSON("/teams.json", { name: request.term }, response);
      },
      messages: {
        noResults: null,
        results: function() {}
      },
      focus: function(event, ui) {
        jQuery(this).val(ui.item.name);
        return false;
      },
      select: function(event, ui) {
        jQuery(this).val(ui.item.name);
        var idField = jQuery('#' + jQuery(this).data('id-field'));
        idField.val(ui.item.id);
        idField.change();
        return false;
      }
    })
    .data("ui-autocomplete")
    ._renderItem = function(ul, item) {
      return jQuery('<li id="team_' + item.id + '"></li>')
          .data("item.autocomplete", item)
          .append('<a>' + item.name + '</a>')
          .appendTo(ul);
    };
  }
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
        error   : function() {
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
      callback: function() {
        jQuery(this).closest('.editing').removeClass('editing');
        return true;
      }
    }
  );
}

jQuery(document).bind("ajax:error", function(event, xhr, status, error) {
   alert('We\'re sorry, but something went wrong (' + error + ')');
 });

jQuery(document).ready(function() {
  makeEditable();
  bindAutocomplete();
  bindAutocompleteTeam();
  jQuery('.wants_focus:visible').select();
});
