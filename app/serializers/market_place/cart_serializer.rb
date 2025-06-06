module MarketPlace
  class CartSerializer < ActiveModel::Serializer
    attributes :id, :total_price

    has_many :cart_items, serializer: MarketPlace::CartItemSerializer

    def total_price
      object.cart_items.sum { |item| item.quantity * item.product.price }
    end
  end
end
