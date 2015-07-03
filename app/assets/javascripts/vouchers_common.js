function calculate_current_row_amount_and_total_number_of_products(this_object) {
  calc_amount(this_object.closest('tr'));
  update_count_of_products();
}

function populate_secondary_entity() {
  if ($('#primary_location').select2('val').length)
  {
    $.ajax({
      url: "/"+$(location).attr('pathname').split('/')[1]+"/get-business-entities",
      dataType: 'json',
      type: 'GET',
      data: {
              business_entity_location_id: $('#primary_location').select2('val'),
              business_entity_id: $('#secondary_business_entity').select2('val')
            },
      success: function (response) {
        $('#secondary_business_entity').find('option')
          .prop('disabled', true)
          .addClass('hidden');
        $.each(response, function(key, value) {
          $('#secondary_business_entity').find('option[value='+value+']')
            .prop('disabled', false)
            .removeClass('hidden');
        });
        $('#secondary_business_entity').trigger('change');
      }
    });
  }
}

$(document).on('ready page:load', function() {
  populate_secondary_entity();

  $('#primary_location').on('change', function() {
    populate_secondary_entity();
  });
});
