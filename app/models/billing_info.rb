class BillingInfo < ApplicationRecord
  belongs_to :user

  validates :full_name, :address_line, :country, :city, :zip, :country_code, :phone, presence: true

  validate :valid_phone_format

  def full_phone
    Phonelib.parse("#{country_prefix}#{phone}").international
  end

  private

  def valid_phone_format
    parsed = Phonelib.parse("#{country_prefix}#{phone}")
    unless parsed.valid?
      errors.add(:phone, "is not a valid international phone number")
    end
  end

  def country_prefix
    country = ISO3166::Country[country_code]
    country&.country_code.to_s
  end
end
