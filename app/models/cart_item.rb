class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id, message: "is already in cart" }
  validate :quantity_does_not_exceed_stock

  def quantity_does_not_exceed_stock
    return if product.blank? || quantity.blank?

    if quantity > product.stock
      errors.add(:quantity, "exceeds available stock (#{product.stock})")
    end
  end
end
