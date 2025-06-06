module MarketPlace
  class OrderSerializer < ActiveModel::Serializer
    attributes :id, :status, :total_price, :created_at,
              :billing_full_name, :billing_phone, :billing_address_line, :billing_city, :billing_zip, :billing_country, :billing_country_code

    has_many :order_items, serializer: MarketPlace::OrderItemSerializer
  end
end
