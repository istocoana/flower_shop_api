module MarketPlace
  class CartItemsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_customer!
    before_action :set_cart
    before_action :set_cart_item, only: [ :update, :destroy ]

    def index
      cart_items = @cart.cart_items.includes(:product)

      if cart_items.empty?
        render json: { message: "Your cart is empty." }, status: :ok
      else
        render json: cart_items, each_serializer: MarketPlace::CartItemSerializer, status: :ok
      end
    end

    def create
      product = Product.find_by(id: params[:product_id])
      return render json: { error: "Product not found" }, status: :not_found unless product

      quantity = params[:quantity].presence&.to_i || 1
      return render json: { error: "Quantity must be at least 1" }, status: :unprocessable_entity if quantity <= 0

      cart_item = @cart.cart_items.find_or_initialize_by(product: product)
      new_quantity = (cart_item.quantity || 0) + quantity

      if new_quantity > product.stock
        return render json: { error: "Cannot add more than available stock (#{product.stock})" }, status: :unprocessable_entity
      end

      cart_item.quantity = new_quantity
      if cart_item.save
        render json: cart_item, serializer: MarketPlace::CartItemSerializer, status: :created
      else
        render json: { error: "Unable to add item", details: cart_item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      quantity = params[:quantity].to_i
      return render json: { error: "Quantity must be at least 1" }, status: :unprocessable_entity if quantity < 1
      return render json: { error: "Quantity exceeds available stock (#{@cart_item.product.stock})" }, status: :unprocessable_entity if quantity > @cart_item.product.stock

      if @cart_item.update(quantity: quantity)
        render json: @cart_item, serializer: MarketPlace::CartItemSerializer, status: :ok
      else
        render json: { error: "Unable to update item", details: @cart_item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @cart_item.destroy
      render json: { message: "Item removed from cart" }, status: :ok
    end

    private

    def authorize_customer!
      render json: { error: "Unauthorized" }, status: :unauthorized unless current_user.customer?
    end

    def set_cart
      @cart = current_user.cart || current_user.create_cart
    end

    def set_cart_item
      @cart_item = @cart.cart_items.find_by(product_id: params[:product_id])
      render json: { error: "Cart item not found" }, status: :not_found unless @cart_item
    end
  end
end
