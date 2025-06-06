module Admin
  class ProductSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :name, :description, :price, :currency, :stock, :status, :created_at, :updated_at, :image_urls
    belongs_to :created_by, serializer: UserSerializer

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
