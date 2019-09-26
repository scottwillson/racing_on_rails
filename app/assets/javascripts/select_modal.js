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
  const row = jQuery(event.target).parent('tr')[0];
  const id = jQuery(row).data(`${type}-id`);
  const name = jQuery(row).data(`${type}-name`);

  jQuery(`#${objectName}_${method}_id`).val(id);
  jQuery(`#${objectName}_${method}_name`).val(name);
  jQuery(`#${objectName}_${method}_name_button`).text(name);

  jQuery(`#${objectName}_${method}_select_modal_button`).removeClass('none');
  jQuery(`#${objectName}_${method}_select_modal`).modal('hide');
  jQuery(`#${objectName}_${method}_remove_button`).show();
}

function searchResultRow(searchResult, type) {
  if (type === 'person') {
    return searchResultPersonCells(searchResult);
  } else if (type === 'team') {
    return searchResultTeamCells(searchResult);
  }
}

function searchResultPersonCells(person) {
  return `<td><span class="glyphicon glyphicon-user"></span></td>
   <td>${person.name}</td>
   <td class="team_name">${person.team_name}</td>
   <td class="city">${city(person)}</td>`
}

function searchResultTeamCells(team) {
  return `<td><span class="glyphicon glyphicon-group"></span></td>
   <td>${team.name}</td>
   <td></td>
   <td></td>`
}

function searchFor(type, objectName, method) {
  if (!jQuery(`#${objectName}_${method}_select_modal`).is(':visible')) {
    return;
  }

  const searchField = $(`#${objectName}_${method}_select_modal_form input.name`)[0];
  const name = searchField.value;

  if (name === '') {
    return Promise.resolve(false);
  }

  const types = pluralize(type);
  const page = parseInt(jQuery(`#${objectName}_${method}_page`).val(), 10);
  return fetch(`/${types}.json?name=${name}&per_page=12&page=${page}`)
    .then(response => response.json())
    .then(json => {
      jQuery(`#${types} tbody`).empty();
      json.forEach(searchResult => {
        jQuery(`#${types} tbody`).append(
          `<tr data-${type}-id=${searchResult.id} data-${type}-name='${searchResult.name}'>
            ${searchResultRow(searchResult, type)}
           </tr>`
        );
      });

      if (json.length === 0) {
        jQuery(`#${types} tbody`).append(
          `<tr>
            <td colspan="4">No results</td>
           </tr>`
        );
      }

      if (page === 1 && json.length === 12) {
        jQuery(`#${objectName}_${method}_previous`).prop('disabled', true);
        jQuery(`#${objectName}_${method}_next`).prop('disabled', false);
      } else if (page === 1 && json.length < 12) {
        jQuery(`#${objectName}_${method}_previous`).prop('disabled', true);
        jQuery(`#${objectName}_${method}_next`).prop('disabled', true);
      } else if (json.length === 12) {
        jQuery(`#${objectName}_${method}_previous`).prop('disabled', false);
        jQuery(`#${objectName}_${method}_next`).prop('disabled', false);
      } else {
        jQuery(`#${objectName}_${method}_previous`).prop('disabled', false);
        jQuery(`#${objectName}_${method}_next`).prop('disabled', true);
      }

      jQuery('.select-modal tr').click(event => selectSearchResult(event, type, objectName, method));
      searchField.select();
    });
}

function searchForPrevious(type, objectName, method) {
  const currentPage = parseInt(jQuery(`#${objectName}_${method}_page`).val(), 10);
  if (currentPage > 1) {
    jQuery(`#${objectName}_${method}_page`).val(currentPage - 1);
  }
  searchFor(type, objectName, method);
}

function searchForNext(type, objectName, method) {
  const currentPage = parseInt(jQuery(`#${objectName}_${method}_page`).val(), 10);
  jQuery(`#${objectName}_${method}_page`).val(currentPage + 1);
  searchFor(type, objectName, method);
}

function showNewModal(type, objectName, method) {
  const searchField = $(`#${objectName}_${method}_select_modal_form input.name`)[0];
  jQuery(`#${objectName}_${method}_select_modal`).modal('hide');
  jQuery(`#${objectName}_${method}_select_modal_new_${type}`).modal('show');
}

function createObject(type, objectName, method) {
  const name = jQuery(`#new_${type}_name`)[0].value;

  jQuery(`#${objectName}_${method}_id`).val("");
  jQuery(`#${objectName}_${method}_name`).val(name);
  jQuery(`#${objectName}_${method}_name_button`).text(name);

  jQuery(`#${objectName}_${method}_select_modal_button`).removeClass('none');
  jQuery(`#${objectName}_${method}_select_modal_new_${type}`).modal('hide');
  jQuery(`#${objectName}_${method}_remove_button`).show();
}

function removeObject(type, objectName, method) {
  jQuery(`#${objectName}_${method}_id`).val("");
  jQuery(`#${objectName}_${method}_name`).val('');
  jQuery(`#${objectName}_${method}_name_button`).text('Click to select');
  jQuery(`#${objectName}_${method}_remove_button`).hide();
  jQuery(`#${objectName}_${method}_select_modal_button`).addClass('none');
}

function bindSelectModal() {
  jQuery('button.select-modal').each((index, element) => {
    const button = jQuery(element);
    const method = button.data('method');
    const objectName = button.data('object-name');
    const type = button.data('type');

    console.log(method, objectName, type, index, `#${objectName}_${method}_select_modal`);

    jQuery(`#${objectName}_${method}_select_modal`).on(
      'shown.bs.modal',
      () => {
        const name = jQuery(`#${objectName}_${method}_name`).val();
        $(`#${objectName}_${method}_select_modal_form input.name`).val(name);
        jQuery(`#${objectName}_${method}_select_modal input.search`).select();
      }
    );

    jQuery(`#${objectName}_${method}_select_modal_form .search`).change(
      () => searchFor(type, objectName, method)
    );

    jQuery(`#${objectName}_${method}_previous`).click(() => searchForPrevious(type, objectName, method));
    jQuery(`#${objectName}_${method}_next`).click(() => searchForNext(type, objectName, method));

    jQuery(`#${objectName}_${method}_select_modal_form`).submit(() => {
      searchFor(type, objectName, method);
      return false;
    });

    jQuery(`#show_${objectName}_${method}_new_modal`).click(() => showNewModal(type, objectName, method));
    jQuery(`#${objectName}_${method}_select_modal_new_${type}_form`).submit(() => {
      createObject(type, objectName, method);
      return false;
    });
    jQuery(`#${objectName}_${method}_select_modal_new_${type}_create`).click(() => createObject(type, objectName, method));

    jQuery(`#${objectName}_${method}_select_modal_new_${type}`).on(
      'shown.bs.modal',
      () => jQuery(`#new_${type}_name`).select()
    );

    jQuery(`#${objectName}_${method}_remove_button`).click(() => removeObject(type, objectName, method));
  });
};

jQuery(document).ready(bindSelectModal);
