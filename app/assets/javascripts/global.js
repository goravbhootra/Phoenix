function set_current_business_entity() {
  if ($('#current_business_entity').select2('val').length)
  {
    $.ajax({
      url: "/current-business-entity",
      dataType: 'text',
      type: 'GET',
      data: {
              current_business_entity_id: $('#current_business_entity').select2('val')
            }
    });
  }
}

$(document).on('ready page:load', function() {
  $("#current_business_entity").select2({dropdownCssClass : 'bigdrop'});
  set_current_business_entity();

  $('#current_business_entity').on('change', function() {
    set_current_business_entity();
  });
});
