require "rails_helper"

RSpec.describe MarketPlace::OrdersController, type: :request do
  let(:customer) { create(:user, role: :customer) }
  let(:product) { create(:product, stock: 10) }
  let!(:cart) { create(:cart, user: customer) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

  let(:valid_billing_info) do
    {
      full_name: "Ana Popa",
      address_line: "Str. Trandafirilor nr. 7",
      city: "Cluj-Napoca",
      country: "Romania",
      zip: "400000",
      country_code: "RO",
      phone: "712345678"
    }
  end

  before do
    sign_in customer
    customer.reload
  end

  describe "POST /orders" do
    it "creates an order and reduces stock" do
      expect {
          post "/orders", params: { billing_info: valid_billing_info }
      }.to change { Order.count }.by(1)
       .and change { OrderItem.count }.by(1)
       .and change { product.reload.stock }.from(10).to(8)

       expect(response).to have_http_status(:created)
    end

    context "when cart is empty" do
      before { cart.cart_items.destroy_all }

      it "returns an error" do
        post "/orders", params: valid_billing_info
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Cart is empty")
      end
    end

    context "when stock is insufficient" do
      before { product.update(stock: 1) }

      it "does not create the order" do
        expect {
          post "/orders", params: valid_billing_info
        }.not_to change { Order.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Order could not be placed")
      end
    end
  end

  describe "GET /orders" do
    let!(:order) { create(:order, user: customer) }

    it "returns list of orders" do
      get "/orders"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
    end
  end

  describe "GET /orders/:id" do
    let!(:order) { create(:order, user: customer) }

    it "shows a specific order" do
      get "/orders/#{order.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(order.id)
    end
  end

  describe "PUT /orders/:id" do
    let!(:order) { create(:order, user: customer, status: :pending) }

    it "updates billing info if order is pending" do
      put "/orders/#{order.id}", params: {
        order: {
          billing_full_name: "Ana Popa",
          billing_address_line: "Str. Noua",
          billing_city: "Cluj",
          billing_zip: "123456",
          billing_country: "Romania",
          billing_country_code: "RO",
          billing_phone: "0712345678"
        }
      }

      expect(response).to have_http_status(:ok)
      expect(order.reload.billing_full_name).to eq("Ana Popa")
    end
  end

  describe "PUT /orders/:id/cancel" do
    let(:cancel_product) { create(:product, stock: 10) }
    let!(:order) do
      create(:order, user: customer, status: :pending).tap do |o|
        create(:order_item, order: o, product: cancel_product, quantity: 2)
      end
    end

    it "cancels the order and restores stock" do
      patch "/orders/#{order.id}/cancel"

      expect(response).to have_http_status(:ok)
      expect(order.reload.status).to eq("cancelled")
      expect(cancel_product.reload.stock).to eq(12)
    end
  end
end
