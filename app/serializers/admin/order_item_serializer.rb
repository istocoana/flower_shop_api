module Admin
  class OrderItemSerializer < ActiveModel::Serializer
    attributes :id, :product_id, :product_name, :quantity, :price

    def product_name
      object.product.name
    end

    def price
      object.product.price
    end
  end
end
