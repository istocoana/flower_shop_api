module MarketPlace
  class OrderItemSerializer < ActiveModel::Serializer
    attributes :id, :product_id, :product_name, :quantity, :price, :total

    def product_name
      object.product.name
    end

    def total
      object.quantity * object.price
    end
  end
end
