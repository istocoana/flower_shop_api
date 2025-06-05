module MarketPlace
  class ProductSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :name, :description, :price, :currency, :stock, :image_urls

    def image_urls
      return [] unless object.images.attached?

      object.images.map do |image|
        Rails.application.routes.url_helpers.rails_blob_url(
          image,
          host: Rails.env.production? ? ENV.fetch("APP_HOST") : "http://localhost:3000"
        )
      end
    end
  end
end
