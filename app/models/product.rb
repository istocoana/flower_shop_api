class Product < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  has_many_attached :images

  enum :currency, { ron: "ron", eur: "eur", usd: "usd" }
  enum :status, { active: "active", inactive: "inactive" }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true, uniqueness: { case_sensitive: false }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
  validates :currency, inclusion: { in: currencies.keys }
  validates :status, inclusion: { in: statuses.keys }

  before_save :deactivate_if_out_of_stock

  private

  def deactivate_if_out_of_stock
    self.status = stock.to_i.zero? ? "inactive" : "active"
  end
end
