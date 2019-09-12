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
  jQuery('#event_promoter_name').text(personName);

  jQuery('#event_promoter_select_modal').modal('hide');
}

function findPeople() {
  const name = $('#event_promoter_select_modal_form #name')[0].value;
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
      jQuery('.select-modal tr').click(selectPerson);
    });
}

function bindSelectModal() {
  jQuery('#event_promoter_select_modal').on(
    'shown.bs.modal',
    () => findPeople().then(() => jQuery('#event_promoter_select_modal_form #name').select())
  );

  jQuery('#event_promoter_select_modal_form #name').change(findPeople);
  jQuery('#event_promoter_select_modal_form').submit(() => false);
};

jQuery(document).ready(bindSelectModal);
