module MarketPlace
  class CartItemSerializer < ActiveModel::Serializer
    attributes :id, :product_id, :product_name, :quantity, :price, :currency, :total

    def product_name
      object.product.name
    end

    def price
      object.product.price
    end

     def currency
      object.product.currency
    end

    def total
      object.quantity * object.product.price
    end
  end
end
