function city(person) {
  if (person.city) {
    return person.city;
  }
  return "";
}

function pluralize(type) {
  if (type === 'person') {
    return 'people';
  } else if (type === 'team') {
    return 'teams';
  }

  return type;
}

function selectSearchResult(event, type, objectName, method) {
  var row = jQuery(event.target).parent('tr')[0];
  var id = jQuery(row).data(type + '-id');
  var name = jQuery(row).data(type + '-name');

  jQuery('#' + objectName + '_' + method + '_id').val(id);
  jQuery('#' + objectName + '_' + method + '_name').val(name);
  jQuery('#' + objectName + '_' + method + '_name_button').text(name);

  jQuery('#' + objectName + '_' + method + '_select_modal_button').removeClass('none');
  jQuery('#' + objectName + '_' + method + '_select_modal').modal('hide');
  jQuery('#' + objectName + '_' + method + '_remove_button').show();
}

function searchResultRow(searchResult, type) {
  if (type === 'person') {
    return searchResultPersonCells(searchResult);
  } else if (type === 'team') {
    return searchResultTeamCells(searchResult);
  }
}

function searchResultPersonCells(person) {
  return '<td><span class="glyphicon glyphicon-user"></span></td>' +
   '<td>' + person.name + '</td>' +
   '<td class="team_name">' + person.team_name + '</td>' +
   '<td class="city">' + city(person) + '</td>'
}

function searchResultTeamCells(team) {
  return '<td><span class="glyphicon glyphicon-group"></span></td>' +
   '<td>' + team.name + '</td>' +
   '<td></td>' +
   '<td></td>'
}

function searchFor(type, objectName, method, selectText) {
  if (!jQuery('#' + objectName + '_' + method + '_select_modal').is(':visible')) {
    return;
  }

  var searchField = jQuery('#' + objectName + '_' + method + '_select_modal_form input.name')[0];
  var name = searchField.value;

  if (name === '') {
    return Promise.resolve(false);
  }

  var types = pluralize(type);
  var page = parseInt(jQuery('#' + objectName + '_' + method + '_page').val(), 10);
  return fetch('/' +types + '.json?name=' + name + '&per_page=12&page=' + page)
    .then(function(response) {
      return response.json();
    })
    .then(function(json) {
      var searchResultsTable = jQuery('#' + objectName + '_' + method + '_select_modal .' + types + ' tbody');
      searchResultsTable.empty();
      json.forEach(function(searchResult) {
        return searchResultsTable.append(
          '<tr data-' + type + '-id="' + searchResult.id + '" data-' + type + '-name="' + searchResult.name + '">' +
            searchResultRow(searchResult, type) +
           '</tr>'
        );
      });

      if (json.length === 0) {
        searchResultsTable.append(
          '<tr><td colspan="4">No results</td></tr>'
        );
      }

      if (page === 0 && json.length === 12) {
        jQuery('#' + objectName + '_' + method + '_previous').prop('disabled', true);
        jQuery('#' + objectName + '_' + method + '_next').prop('disabled', false);
      } else if (page === 0 && json.length < 12) {
        jQuery('#' + objectName + '_' + method + '_previous').prop('disabled', true);
        jQuery('#' + objectName + '_' + method + '_next').prop('disabled', true);
      } else if (json.length === 12) {
        jQuery('#' + objectName + '_' + method + '_previous').prop('disabled', false);
        jQuery('#' + objectName + '_' + method + '_next').prop('disabled', false);
      } else {
        jQuery('#' + objectName + '_' + method + '_previous').prop('disabled', false);
        jQuery('#' + objectName + '_' + method + '_next').prop('disabled', true);
      }

      jQuery('.select-modal tr').click(function(event) { return selectSearchResult(event, type, objectName, method); });
      if (selectText) {
        searchField.select();
      }
    });
}

function searchForPrevious(type, objectName, method) {
  var currentPage = parseInt(jQuery('#' + objectName + '_' + method + '_page').val(), 10);
  if (currentPage > 1) {
    jQuery('#' + objectName + '_' + method + '_page').val(currentPage - 1);
  }
  return searchFor(type, objectName, method, true);
}

function searchForNext(type, objectName, method) {
  var currentPage = parseInt(jQuery('#' + objectName + '_' + method + '_page').val(), 10);
  jQuery('#' + objectName + '_' + method + '_page').val(currentPage + 1);
  return searchFor(type, objectName, method, true);
}

function showNewModal(type, objectName, method) {
  jQuery('#' + objectName + '_' + method + '_select_modal').modal('hide');
  jQuery('#' + objectName + '_' + method + '_select_modal_new_' + type).modal('show');
}

function createObject(type, objectName, method) {
  var name = jQuery('#' + objectName + '_' + method + '_select_modal_form input.name')[0].value;

  jQuery('#' + objectName + '_' + method + '_id').val("");
  jQuery('#' + objectName + '_' + method + '_name').val(name);
  jQuery('#' + objectName + '_' + method + '_name_button').text(name);

  jQuery('#' + objectName + '_' + method + '_select_modal_button').removeClass('none');
  jQuery('#' + objectName + '_' + method + '_select_modal_new_' + type).modal('hide');
  jQuery('#' + objectName + '_' + method + '_remove_button').show();
}

function removeObject(type, objectName, method) {
  jQuery('#' + objectName + '_' + method + '_id').val("");
  jQuery('#' + objectName + '_' + method + '_name').val('');
  jQuery('#' + objectName + '_' + method + '_name_button').text('Click to select');
  jQuery('#' + objectName + '_' + method + '_remove_button').hide();
  jQuery('#' + objectName + '_' + method + '_select_modal_button').addClass('none');
}

function bindSelectModal() {
  jQuery('button.select-modal').each(function(index, element) {
    var button = jQuery(element);
    var method = button.data('method');
    var objectName = button.data('object-name');
    var type = button.data('type');

    jQuery('#' + objectName + '_' + method + '_select_modal').on(
      'shown.bs.modal',
      function() {
        var name = jQuery('#' + objectName + '_' + method + '_name').val();
        jQuery('#' + objectName + '_' + method + '_select_modal_form input.name').val(name);
        jQuery('#' + objectName + '_' + method + '_select_modal input.search').select();
      }
    );

    jQuery('#' + objectName + '_' + method + '_select_modal input.search').keyup(
      function() {
        if (jQuery('#' + objectName + '_' + method + '_select_modal_form input.name')[0].value.length > 2) {
          jQuery('#' + objectName + '_' + method + '_page').val(0);
          return searchFor(type, objectName, method, false);
        }
      }
    );

    jQuery('#' + objectName + '_' + method + '_previous').click(function() {
      return searchForPrevious(type, objectName, method);
    });

    jQuery('#' + objectName + '_' + method + '_next').click(function() {
      return searchForNext(type, objectName, method);
    });

    jQuery('#' + objectName + '_' + method + '_select_modal_form').submit(function() {
      jQuery('#' + objectName + '_' + method + '_page').val(0);
      searchFor(type, objectName, method, true);
      return false;
    });

    jQuery('#show_' + objectName + '_' + method + '_new_modal').click(function() {
      return showNewModal(type, objectName, method);
    });

    jQuery('#' + objectName + '_' + method + '_select_modal_new_' + type + '_form').submit(function() {
      createObject(type, objectName, method);
      return false;
    });

    jQuery('#' + objectName + '_' + method + '_select_modal_new_' + type + '_create').click(function() {
      return createObject(type, objectName, method);
    });

    jQuery('#show_' + objectName + '_' + method + '_new_modal').on(
      'shown.bs.modal',
      function() {
        jQuery('#' + objectName + '_' + method + '_select_modal_new_' + type + ' input.name').select();
      }
    );

    jQuery('#' + objectName + '_' + method + '_remove_button').click(function() {
      return removeObject(type, objectName, method);
    });
  });
};

jQuery(document).ready(bindSelectModal);
