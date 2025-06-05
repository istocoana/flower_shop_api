class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum :status, {
    pending: "pending",
    confirmed: "confirmed",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled"
  }

  validates :status, inclusion: { in: statuses.keys }
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  before_create :set_placed_at, :set_default_status
  after_update :restore_stock_if_cancelled

  private

  def set_placed_at
    self.created_at ||= Time.current
  end

  def set_default_status
    self.status ||= "pending"
  end

  def restore_stock_if_cancelled
    return unless saved_change_to_status? && cancelled?

    ActiveRecord::Base.transaction do
      order_items.includes(:product).each do |item|
        item.product.update!(stock: item.product.stock + item.quantity)
      end
    end
  end
end
