RailsAdmin.config do |config|
  config.authorize_with :cancan

  # config.included_models = ['Product', 'ProductGroup', 'Author', 'BusinessEntity',
  #                           'Category', 'City', 'CoreLevel', 'Currency',
  #                           'DistributionType', 'Language', 'Member', 'PaymentMode', 'Publisher',
  #                           'Region', 'State', 'Uom', 'User', 'StateCategoryTaxRate', 'Zone'
  #                         ]
  config.excluded_models = ['InventoryTxn', 'InventoryTxnLineItem', 'InvoicePayment',
                            'InventoryOutVoucher', 'PosInvoice', 'InventoryInVoucher',
                            'Order', 'Order::LineItem', 'InventoryInternalTransferVoucher',
                            'InventoryVoucher', 'InventoryVoucherLineItem',
                            'Invoice', 'InvoiceLineItem', 'PosVoucher',
                            'InvoicesVoucher', 'InventoryTxnFilter',
                            'SignIn', 'InventoryReport', 'LocationInventoryLevel',
                            'VoucherSequence', 'Product', 'InventoryTxnVouchersReport',
                            'JournalVoucher', 'MyAccount',
                            'Account', 'Account::Asset', 'Account::Liability',
                            'Account::SundryDebtor', 'Account::SundryCreditor',
                            'Account::CurrentAsset',
                            'Account::CurrentLiability', 'Account::SalesAccount',
                            'AccountTxn', 'AccountTxnDetail', 'AccountEntry',
                            'AccountEntry::Debit', 'AccountEntry::Credit', 'InvoiceHeader'
                          ]

  config.actions do
    dashboard do                  # mandatory
      statistics false
    end
    index                         # mandatory
    new
    export
    # bulk_delete
    show
    edit
    # delete
    # show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  # config.model Order do
  #   exclude_fields :id
  #   weight -60
  # end

  # config.model Order::LineItem do
  #   visible false
  # end

  # config.model Member do
  #   exclude_fields :inventory_out_vouchers, :id, :created_at, :updated_at
  #   weight -41
  # end

  ['Author', 'CoreLevel', 'DistributionType', 'PaymentMode', 'Uom', 'Publisher', 'FocusGroup'].each do |modelname|
    config.model modelname do
      exclude_fields :id, :position, :created_at, :updated_at
      navigation_label 'Configuration'
      weight 0
    end
  end

  config.model Currency do
    exclude_fields :id, :position, :created_at, :updated_at, :reserved
    navigation_label 'Configuration'
    weight 0
  end

  # config.model VoucherSequence do
  #   list do
  #     filters [:business_entity]
  #     exclude_fields :id, :position, :created_at, :updated_at
  #     field :business_entity
  #     field :classification do
  #       filterable false
  #     end
  #     field :number_prefix
  #     field :starting_number
  #     field :valid_from
  #     field :valid_till
  #     field :terms_conditions
  #     field :active
  #   end
  #   navigation_label 'Configuration'
  #   weight 0
  # end

  config.model BusinessEntity do
    list do
      scopes [:unreserved]
    end
    exclude_fields :id, :position, :created_at, :updated_at, :voucher_sequences, :publisher, :reserved
    navigation_label 'Configuration'
    weight -31
  end

  config.model BusinessEntityLocation do
    exclude_fields :id, :position, :created_at, :updated_at
    visible false
  end

  config.model Language do
    field :name
    field :code
    field :active
    field :parent_id, :enum do
      enum_method do
        :parent_enum
      end
    end
    exclude_fields :id, :position, :created_at, :updated_at
    navigation_label 'Configuration'
    weight 0
  end

  config.model Category do
    field :name
    field :code
    field :active
    field :parent_id, :enum do
      enum_method do
        :parent_enum
      end
    end
    exclude_fields :id, :position, :created_at, :updated_at
    navigation_label 'Configuration'
    weight 0
  end

  config.model StateCategoryTaxRate do
    field :state
    field :category_id, :enum do
      enum_method do
        :category_enum
      end
    end
    field :classification
    field :interstate_label
    field :interstate_rate
    field :intrastate_label
    field :intrastate_rate
    field :valid_from do
      strftime_format "%d/%m/%Y"
    end
    field :valid_till do
      strftime_format "%d/%m/%Y"
    end
    field :active
    exclude_fields :id, :position, :created_at, :updated_at
    navigation_label 'Configuration'
    weight 0
  end

  ['City', 'Zone'].each do |name|
    config.model name do
      list do
        scopes [:unreserved]
      end
      exclude_fields :id, :position, :created_at, :updated_at, :reserved
      navigation_label 'Geolocation'
    end
  end

  config.model Region do
    exclude_fields :id, :position, :created_at, :updated_at, :reserved
    navigation_label 'Geolocation'
    weight 50
  end

  config.model State do
    exclude_fields :id, :position, :state_category_tax_rates, :created_at, :updated_at, :reserved
    navigation_label 'Geolocation'
  end

  config.model User do
    field :name
    field :email
    field :membership_number
    field :city
    field :contact_number_primary
    field :contact_number_secondary
    field :address
    field :active
    field :cash_account_id
    list do
      field :confirmed_at
      field :current_sign_in_at
    end
    # visible false
    exclude_fields :id, :position, :created_at, :updated_at
  end

  config.model ProductGroup do
    exclude_fields :id, :position, :created_at, :updated_at
    weight -50
  end

  # RailsAdmin.config do |config|
  #   config.model Product do
  #     [list, show].each do
  #       field :sku
  #       field :name
  #       field :language
  #       field :alias_name
  #       field :category
  #       field :active
  #       field :selling_price
  #       field :distribution_type
  #       field :product_group
  #       field :core_level
  #       field :author
  #       field :isbn
  #       field :summary
  #       field :synopsis
  #       field :publication_date
  #       field :mrp
  #       field :notes
  #       field :uom
  #     end

  #     exclude_fields :inventory_txn_line_items, :position, :id, :created_at, :updated_at
  #     field :publisher do
  #       pretty_value do
  #         value.name
  #       end
  #     end
  #     weight -51
  #   end
  # end

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration
end
