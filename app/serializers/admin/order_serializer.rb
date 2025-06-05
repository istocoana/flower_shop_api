module Admin
  class OrderSerializer < ActiveModel::Serializer
    attributes :id, :status, :total_price, :created_at,
               :customer_email, :customer_name,
               :billing_full_name, :billing_address_line, :billing_city,
               :billing_zip, :billing_country, :billing_country_code, :billing_phone,
               :order_items

    def customer_email
      object.user.email
    end

    def customer_name
      object.billing_full_name
    end

    def order_items
      object.order_items.map do |item|
        {
          id: item.id,
          product_id: item.product_id,
          product_name: item.product.name,
          quantity: item.quantity,
          price: item.price,
          total: item.quantity * item.price
        }
      end
    end
  end
end
