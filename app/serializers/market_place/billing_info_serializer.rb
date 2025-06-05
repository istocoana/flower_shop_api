module MarketPlace
  class BillingInfoSerializer < ActiveModel::Serializer
    attributes :full_name, :address_line, :country, :city, :zip, :country_code, :phone, :full_phone

    def full_phone
      object.full_phone
    end
  end
end
