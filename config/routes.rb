Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/masters', as: 'rails_admin'

  # root :to => redirect('/masters')
  root :to => "sessions#new"
  get '/login' => 'sessions#new'
  get '/logout' => 'sessions#destroy'
  delete '/logout' => 'sessions#destroy'
  # get 'current-business-entity' => 'application#current_business_entity'

  resources :sessions, only: [:new, :create, :destroy]

  get '/pos-invoices/get-voucher-sequences' => 'pos_invoices#get_voucher_sequences'

  get '/inventory-out-vouchers/get-voucher-sequences' => 'inventory_out_vouchers#get_voucher_sequences'
  get '/inventory-out-vouchers/get-business-entities' => 'inventory_out_vouchers#get_business_entities'

  get '/inventory-in-vouchers/get-voucher-sequences' => 'inventory_in_vouchers#get_voucher_sequences'
  get '/inventory-in-vouchers/get-business-entities' => 'inventory_in_vouchers#get_business_entities'
  get '/inventory-internal-transfer-vouchers/get-voucher-sequences' => 'inventory_internal_transfer_vouchers#get_voucher_sequences'
  get '/inventory-internal-transfer-vouchers/get-entity-locations' => 'inventory_internal_transfer_vouchers#get_entity_locations'

  get '/inventory-transactions/summary-report' => 'inventory_txn_reports#index'

  get '/pos-invoice-payments' => 'pos_invoices#payment'

  resources :pos_invoices, path: 'pos-invoices'
  resources :inventory_out_vouchers, path: 'inventory-out-vouchers'
  resources :inventory_in_vouchers, path: 'inventory-in-vouchers'
  resources :inventory_internal_transfer_vouchers, path: 'inventory-internal-transfer-vouchers'

  resources :users

  get '/sales-report' => 'reports#sales'
  get '/payment-collection' => 'reports#payment_collection'
  # get '/stock-summary' => 'reports#stock_summary'
  get '/stock-summary' => 'inventory_reports#stock_summary'
  # get '/opening-stock' => 'inventory_reports#opening_stock'
  get '/invoices-pending' => 'invoices_vouchers#pending_list'

  resources :states
  resources :voucher_sequences, path: 'voucher-sequences', except: :show

  # AWS health check
  get '/ping' => 'ping#show'
  # get '/sales' => 'reports#index'
  # resources :authors
  # resources :business_entities
  # resources :categories
  # resources :cities
  # resources :core_levels
  # resources :currencies
  # resources :distribution_types
  # resources :languages
  # resources :orders
  # resources :payment_modes
  # resources :products
  # resources :product_groups
  # resources :publishers
  # resources :regions
  # resources :states
  # resources :state_category_tax_rates, path: 'tax-rates'
  # resources :uoms
  # resources :users
  # resources :zones
  #   collection do
  #     get 'get_product_details'
  #   end
  # end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
