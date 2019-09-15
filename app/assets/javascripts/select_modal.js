function city(person) {
  if (person.city) {
    return person.city;
  }
  return "";
}

function selectPerson(event) {
  const row = jQuery(event.target).parent('tr')[0];
  const personId = jQuery(row).data('person-id');
  const personName = jQuery(row).data('person-name');

  jQuery('#event_promoter_id').val(personId);
  jQuery('#event_promoter_name').val(personName);
  jQuery('#event_promoter_name_button').text(personName);

  jQuery('#event_promoter_select_modal_button').removeClass('none');
  jQuery('#event_promoter_select_modal').modal('hide');
  jQuery('#event_promoter_remove_button').show();
}

function findPeople() {
  const name = $('#event_promoter_select_modal_form .search')[0].value;

  if (name === '') {
    jQuery('#event_promoter_select_modal_form .search').select();
    return Promise.resolve(false);
  }

  return fetch(`/people.json?name=${name}`)
    .then(response => response.json())
    .then(json => {
      jQuery('#people tbody').empty();
      json.forEach(person => {
        jQuery('#people tbody').append(
          `<tr data-person-id=${person.id} data-person-name='${person.name}'>
            <td><span class="glyphicon glyphicon-user"></span></td>
            <td>${person.name}</td>
            <td class="team_name">${person.team_name}</td>
            <td class="city">${city(person)}</td>
          </tr>`
        );
      });

      if (json.length === 0) {
        jQuery('#people tbody').append(
          `<tr>
            <td colspan="4">No results</td>
          </tr>`
        );
      }

      jQuery('.select-modal tr').click(selectPerson);
      jQuery('#event_promoter_select_modal_form .search').select();
    });
}

function newPerson() {
  const name = $('#event_promoter_select_modal_form .search')[0].value;
  jQuery('#new_person_name').val(name);

  jQuery('#event_promoter_select_modal').modal('hide');
  jQuery('#event_promoter_select_modal_new_person').modal('show');
}

function createPerson() {
  const personName = jQuery('#new_person_name')[0].value;

  jQuery('#event_promoter_id').val("");
  jQuery('#event_promoter_name').val(personName);
  jQuery('#event_promoter_name_button').text(personName);

  jQuery('#event_promoter_select_modal_button').removeClass('none');
  jQuery('#event_promoter_select_modal_new_person').modal('hide');
  jQuery('#event_promoter_remove_button').show();
}

function removePerson() {
  jQuery('#event_promoter_id').val("");
  jQuery('#event_promoter_name').val('');
  jQuery('#event_promoter_name_button').text('Click to select');
  jQuery('#event_promoter_remove_button').hide();
  jQuery('#event_promoter_select_modal_button').addClass('none');
}

function bindSelectModal() {
  jQuery('#event_promoter_select_modal').on(
    'shown.bs.modal',
    () => findPeople().then(() => jQuery('#event_promoter_select_modal_form .search').select())
  );

  jQuery('#event_promoter_select_modal_form .search').change(findPeople);
  jQuery('#event_promoter_select_modal_form').submit(() => false);
  jQuery('#show_event_promoter_new_modal').click(newPerson);

  jQuery('#event_promoter_select_modal_new_person_form').submit(() => false);
  jQuery('#event_promoter_select_modal_new_person').on(
    'shown.bs.modal',
    () => findPeople().then(() => jQuery('#new_person_name').select())
  );
  jQuery('#event_promoter_select_modal_new_person_create').click(createPerson);
  jQuery('#event_promoter_remove_button').click(removePerson);
};

jQuery(document).ready(bindSelectModal);
