//= require voucher_with_line_items
//= require vouchers_common

$(document).on('ready page:load', function() {
  $('.DataTable-line-items').on('click', '.voucher_line_item_remove', function() {
    $(this).closest('tr').hide().find('.line_item_destroy').val('1');
    clear_row($(this));
    // quantity_field.css({'background-color':'red'});
    // tr_row.contents('td').css('border', '2px dashed red');
  });
});
