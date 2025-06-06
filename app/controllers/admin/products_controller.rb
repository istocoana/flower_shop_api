module Admin
  class ProductsController < ApplicationController
    include AdminAuthorization

    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_product, only: [ :update, :destroy, :toggle_status ]

    def index
      products = Product.includes(:created_by)
      products = products.where(status: params[:status]) if params[:status].present?
      products = products.order(created_at: :desc)

      render json: products, each_serializer: Admin::ProductSerializer, status: :ok
    rescue => e
      render json: { error: "Failed to fetch products", details: e.message }, status: :internal_server_error
    end

    def show
      product = Product.find(params[:id])
      render json: product, serializer: Admin::ProductSerializer, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Product not found" }, status: :not_found
    rescue => e
      render json: { error: "Failed to fetch product", details: e.message }, status: :internal_server_error
    end

    def toggle_status
      @product.status = @product.active? ? :inactive : :active
      if @product.save
        render json: { message: "Product status updated", status: @product.status }, status: :ok
      else
        render json: { error: "Failed to update status", details: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def create
      product = current_user.products.build(product_params)
      if product.save
        render json: product, serializer: Admin::ProductSerializer, status: :created
      else
        render json: { error: "Create failed", details: product.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @product.update(product_params)
        render json: @product, serializer: Admin::ProductSerializer
      else
        render json: { error: "Update failed", details: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      render json: { message: "Product deleted" }
    end

    private

    def set_product
      @product = Product.find_by(id: params[:id])
      render json: { error: "Not found" }, status: :not_found unless @product
    end

    def product_params
      params.require(:product).permit(
        :name, :description, :price, :stock, :currency, :status,
        images: []
      )
    end
  end
end
