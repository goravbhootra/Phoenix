//= require voucher_with_line_items

function calculate_current_row_amount_and_total_number_of_products(this_object) {
  calc_amount(this_object.closest('tr'));
  update_count_of_products();
  update_change_due();
}

function populate_invoice_values_on_page_reload() {
  calc_total_payment();
  update_change_due();
  show_payment_details_if_credit_card_amount_populated();
}

function show_payment_details_if_credit_card_amount_populated() {
  if(parseFloat($('#payment_mode_credit_card_amount').val()) > 0) {
    $('#payment_details').show();
  } else {
    $('#payment_details').hide();
  }
}

function calc_total_payment() {
  var total_payment = 0;
  $('.payment_amount').each(function() {
    if ($.isNumeric($(this).val())) {
      total_payment += parseFloat($(this).val());
    }
  });
  $('#payment_total').text(parseFloat(total_payment).toFixed(2));
  update_change_due();
}

function update_change_due() {
  var change_tendered = 0;
  $('.change_tendered').each(function() {
    if ($.isNumeric($(this).val())) {
      change_tendered += parseFloat($(this).val());
    }
  });
  $('#change_tendered_label').text(parseFloat(change_tendered).toFixed(2));

  if ($('#payment_total').text() > 0) {
    $('#change_due').text(parseFloat($('#payment_total').text()-$('#voucher_amount').text()-change_tendered).toFixed(2));
  } else {
    $('#change_due').text(parseFloat('0.00').toFixed(2));
  }
}

$(document).on('ready page:load', function() {
  populate_invoice_values_on_page_reload();

  if($('#pdf_print').length) {
  //   $('#pdf_print')[0].click();
    window.print();
    window.print();
    // $('#open_new_invoice')[0].click();
  }

  $(function() {
    return $('#pos_invoice_index').dataTable({
      processing: true,
      serverSide: true,
      ajax: $('#pos_invoice_index').data('source'),
      aLengthMenu: [[15, 30, 60, 120, 240], [15, 30, 60, 120, 240]],
      pagingType: 'full_numbers',
      order: [[ 0, "desc" ], [ 1, "desc" ]],
      sPaginationType: "bootstrap",
      columns: [
                  {"sClass": "text-center"},
                  {"sClass": "text-center"},
                  {"sClass": "text-center", "sortable": false},
                  {"sClass": "text-center"},
                  {"sClass": "text-right", "sortable": false},
                  {"sClass": "text-center"},
                  {"sClass": "text-center", "sortable": false}
                ]
    });
  });

  $('form').on('keydown', '#customer_membership_number', function(event) {
    if(event.keyCode == 13) {
      $('#s2id_pos_invoice_line_items_attributes_0_sku').select2('focus');
      event.preventDefault();
      return false;
    }
  });

  $('form').on('blur', '#customer_membership_number', function(event) {
    if ($(this).val().length > 9) {
      $(this).val($(this).val().substr(0,9));
    }
  });

  $('form').on('change', '#payment_mode_cash_amount', function(event) {
    if (parseFloat($(this).val()) == parseFloat($('#voucher_amount').text())) {
      $('#save_button').focus();
    }
    else if (parseFloat($(this).val()) > parseFloat($('#voucher_amount').text())) {
      $('#payment_mode_cash_tendered_amount').focus();
    }
  });


  $('#voucher_payments').on('change', '.payment_amount, .change_tendered', function(event) {
    calc_total_payment();
    if (parseInt($(this).val()) == 0 || ($(this).val() == null) || ($(this).val() == '')) {
      $(this).closest('tr').find('.payment_destroy').val('1');
      if ($(this).attr("id") == 'payment_mode_credit_card_amount') {
        $('#payment_details').hide();
      }
    } else {
      $(this).closest('tr').find('.payment_destroy').val('0');
      if ($(this).attr("id") == 'payment_mode_credit_card_amount') {
        $('#payment_details').show();
        $('#bank_name').focus();
      }
    }
  });
});

$(document).on('click', '#save_button', function(event) {
  if(parseFloat($('#payment_total').text()) < parseFloat($('#voucher_amount').text())) {
    alert('Total payment cannot be less than Invoice Amount');
    $('.payment_amount:first').focus();
    return event.preventDefault();
  }
  if(parseFloat($('#payment_mode_cash_tendered_amount').val()) > parseFloat($('#payment_mode_cash_amount').val())) {
    alert('Change tendered cannot be more than cash received. Cannot save the record');
    $('.change_tendered:first').focus();
    return event.preventDefault();
  }

  if(parseInt($('#change_due').text()) != 0) {
    alert('Correct change needs to be tendered to customer');
    $('.change_tendered:first').focus();
    return event.preventDefault();
  }
});
