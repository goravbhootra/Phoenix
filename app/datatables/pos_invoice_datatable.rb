class PosInvoiceDatatable < AjaxDatatablesRails::Base
  include AjaxDatatablesRails::Extensions::Kaminari

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= cols
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= cols
  end

  private

  def cols
    ['PosInvoice.txn_date',
       'PosInvoice.number',
       'BusinessEntityLocation.name',
       'User.name'
     ]
  end

  def data
    records.map do |record|
      [
        # comma separated list of the values for each cell of a table row
        # example: record.attribute,
        record.txn_date.strftime('%d/%m/%Y'),
        record.number,
        record.location_entity_name,
        record.business_entity_location_name,
        record.total_amount,
        record.created_by.custom_object_label,
        "#{link_to("PDF version", pos_invoice_url(record.id, format: "pdf"), target: :_blank)} |
                #{link_to('Edit', edit_pos_invoice_path(record.id))}"
      ]
    end
  end

  def get_raw_records
    PosInvoice.includes(:line_items, [header: [business_entity_location: :business_entity]], :created_by).select("account_txns.*, (select SUM(invoice_line_items.amount) FROM invoice_line_items WHERE invoice_line_items.account_txn_id=account_txns.id) AS total_amount").references(:line_items, :header, :created_by)
  end

  # ==== Insert 'presenter'-like methods below if necessary
  def_delegators :@view, :link_to, :h, :pos_invoice_url, :edit_pos_invoice_path
end
