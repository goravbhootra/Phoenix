json.array!(@orders) do |order|
  json.extract! order, :id, :currency, :business_entity_user, :remarks, :amount, :number
  json.url order_url(order, format: :json)
end
