module MarketPlace
  class OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_customer!
    before_action :set_order, only: [ :show, :update, :cancel ]

    def index
      orders = current_user.orders.includes(:order_items).order(created_at: :desc)
      render json: orders, each_serializer: MarketPlace::OrderSerializer, status: :ok
    rescue => e
      render json: { error: "Unable to fetch orders", details: e.message }, status: :internal_server_error
    end

    def show
      render json: @order, serializer: MarketPlace::OrderSerializer
    rescue => e
      render json: { error: "Unable to fetch order", details: e.message }, status: :internal_server_error
    end

    def create
      if current_user.cart.blank? || current_user.cart.cart_items.empty?
        return render json: { error: "Cart is empty" }, status: :unprocessable_entity
      end

      ActiveRecord::Base.transaction do
        billing_info = current_user.billing_info || current_user.build_billing_info
        billing_info.assign_attributes(billing_info_params)
        billing_info.save!

        order = current_user.orders.create!(
          billing_full_name: billing_info.full_name,
          billing_address_line: billing_info.address_line,
          billing_city: billing_info.city,
          billing_zip: billing_info.zip,
          billing_country: billing_info.country,
          billing_country_code: billing_info.country_code,
          billing_phone: billing_info.phone,
          status: :pending
        )

        order_items_total = 0

        current_user.cart.cart_items.includes(:product).each do |cart_item|
          product = Product.lock.find(cart_item.product.id)

          if cart_item.quantity > product.stock
            raise ActiveRecord::RecordInvalid.new(order), "Insufficient stock for #{product.name}"
          end

          item_total = cart_item.quantity * product.price
          order_items_total += item_total

          order.order_items.create!(
            product: product,
            quantity: cart_item.quantity,
            price: product.price
          )

          product.update!(stock: product.stock - cart_item.quantity)
        end

        order.update!(total_price: order_items_total)
        current_user.cart.cart_items.destroy_all

        render json: order, serializer: MarketPlace::OrderSerializer, status: :created
        broadcast_order_change(order, "order_created")
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "Order could not be placed", details: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue => e
      render json: { error: "Order could not be placed", details: e.message }, status: :unprocessable_entity
    end

    def update
      if @order.pending?
        if @order.update(billing_info_update_params)
          render json: @order, serializer: MarketPlace::OrderSerializer
          broadcast_order_change(@order, "order_updated")
        else
          render json: { error: "Could not update order", details: @order.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: "Only pending orders can be updated" }, status: :forbidden
      end
    end

    def cancel
      unless @order.pending?
        return render json: { error: "Only pending orders can be cancelled" }, status: :forbidden
      end

      ActiveRecord::Base.transaction do
        @order.update!(status: :cancelled)
      end

      render json: { message: "Order cancelled successfully" }, status: :ok
      broadcast_order_change(@order, "order_cancelled")
    rescue => e
      render json: { error: "Could not cancel order", details: e.message }, status: :internal_server_error
    end

    private

    def billing_info_params
      params.require(:billing_info).permit(:full_name, :address_line, :city, :zip, :country, :country_code, :phone)
    end

    def billing_info_update_params
      params.require(:order).permit(:billing_full_name, :billing_address_line, :billing_city, :billing_zip, :billing_country, :billing_country_code, :billing_phone)
    end

    def set_order
      @order = current_user.orders.find_by(id: params[:id])
      render json: { error: "Order not found" }, status: :not_found unless @order
    end

    def authorize_customer!
      render json: { error: "Unauthorized" }, status: :unauthorized unless current_user.customer?
    end

    def broadcast_order_change(order, event_type)
      ActionCable.server.broadcast("orders", {
        type: event_type,
        order: Admin::OrderSerializer.new(order).as_json
      })
    end
  end
end
