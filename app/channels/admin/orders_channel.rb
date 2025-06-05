module Admin
  class OrdersChannel < ApplicationCable::Channel
    def subscribed
      reject unless current_user&.admin?

      stream_from "admin_orders"
    end

    def unsubscribed
      # Any cleanup needed when channel is unsubscribed
    end
  end
end
