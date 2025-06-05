module Admin
  class OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_order, only: [ :update, :show ]

    def index
      orders = Order.includes(:user, :order_items)
      orders = orders.where(status: params[:status]) if params[:status].present?
      orders = orders.order(created_at: :desc)

      if orders.any?
        render json: orders, each_serializer: Admin::OrderSerializer, status: :ok
      else
        render json: { message: "No orders found." }, status: :ok
      end
    end

    def show
      if @order
        render json: @order, serializer: Admin::OrderSerializer, status: :ok
      else
        render json: { error: "Order not found" }, status: :not_found
      end
    end

    def update
      if @order.nil?
        render json: { error: "Order not found" }, status: :not_found
      elsif params[:status].blank?
        render json: { error: "Status is required" }, status: :unprocessable_entity
      elsif Order.statuses.keys.exclude?(params[:status])
        render json: { error: "Invalid status" }, status: :unprocessable_entity
      elsif @order.cancelled?
        render json: { error: "Cannot change status of a cancelled order" }, status: :unprocessable_entity
      elsif @order.update(status: params[:status])
        admin_orders_broadcast(@order)
        render json: @order, serializer: Admin::OrderSerializer, status: :ok
      else
        render json: { error: "Failed to update status", details: @order.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_order
      @order = Order.find_by(id: params[:id])
    end

    def authorize_admin!
      render json: { error: "Unauthorized" }, status: :unauthorized unless current_user.admin?
    end

    def admin_orders_broadcast(order)
      ActionCable.server.broadcast("admin_orders", {
        order: Admin::OrderSerializer.new(order).as_json
      })
    end
  end
end
