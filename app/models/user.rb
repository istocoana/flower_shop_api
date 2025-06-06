class User < ApplicationRecord
  devise :database_authenticatable,
          :registerable,
          :jwt_authenticatable,
          jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  enum :role, { admin: "admin", customer: "customer" }

  has_many :products, foreign_key: :created_by_id, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_one :billing_info, dependent: :destroy
  accepts_nested_attributes_for :billing_info, allow_destroy: true

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
end
