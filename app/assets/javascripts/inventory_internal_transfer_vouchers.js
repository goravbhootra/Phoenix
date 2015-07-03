//= require voucher_with_line_items

function calculate_current_row_amount_and_total_number_of_products(this_object) {
  calc_amount(this_object.closest('tr'));
  update_count_of_products();
}

function populate_secondary_location() {
  if ($('#primary_location').select2('val').length)
  {
    $.ajax({
      url: "/"+$(location).attr('pathname').split('/')[1]+"/get-entity-locations",
      dataType: 'json',
      type: 'GET',
      data: {
              primary_location_id: $('#primary_location').select2('val'),
              secondary_location_id: $('#secondary_location').select2('val')
            },
      success: function (response) {
        $('#secondary_location').find('option')
          .prop('disabled', true)
          .addClass('hidden');
        $.each(response, function(key, value) {
          $('#secondary_location').find('option[value='+value+']')
            .prop('disabled', false)
            .removeClass('hidden');
        });
        $("#secondary_location").trigger('change');
      }
    });
  } else {
    $('#secondary_location').find('option')
      .prop('disabled', true)
      .addClass('hidden');
    $("#secondary_location").trigger('change');
  }
}

$(document).on('ready page:load', function() {
  populate_secondary_location();

  $('#primary_location').on('change', function() {
    populate_secondary_location();
  });
});
