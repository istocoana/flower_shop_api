module MarketPlace
  class ProductsController < ApplicationController
    before_action :authenticate_user!, except: [ :index, :show ]
    before_action :set_product, only: [ :show ]

    def index
      products = Product.where(status: :active).includes(:created_by).order(created_at: :desc)

      if products.any?
        render json: products, each_serializer: MarketPlace::ProductSerializer, status: :ok
      else
        render json: { message: "No active products available" }, status: :ok
      end
    rescue => e
      Rails.logger.error("Failed to load products: #{e.message}")
      render json: { error: "Unable to fetch products", details: e.message }, status: :internal_server_error
    end

    def show
      render json: @product, serializer: MarketPlace::ProductSerializer, status: :ok
    rescue => e
      Rails.logger.error("Failed to load product ##{params[:id]}: #{e.message}")
      render json: { error: "Unable to fetch product", details: e.message }, status: :internal_server_error
    end

    private

    def set_product
      @product = Product.find_by(id: params[:id], status: :active)
      render json: { error: "Product not found" }, status: :not_found unless @product
    end
  end
end
