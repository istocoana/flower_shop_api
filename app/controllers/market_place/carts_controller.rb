module MarketPlace
  class CartsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_customer!
    before_action :set_cart

    def show
      if @cart.cart_items.any?
        render json: @cart, serializer: MarketPlace::CartSerializer, status: :ok
      else
        render json: { cart: {}, message: "Cart is empty." }, status: :ok
      end
    end

    private

    def set_cart
      @cart = current_user.cart || current_user.create_cart!
    end

    def ensure_customer!
      render json: { error: "Access denied" }, status: :forbidden unless current_user.customer?
    end
  end
end
