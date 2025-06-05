require 'rails_helper'

RSpec.describe 'MarketPlace::CartsController', type: :request do
  let(:customer) { create(:user, role: :customer) }
  let!(:cart) { create(:cart, user: customer) }
  let!(:product) { create(:product, stock: 10) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

  before do
    sign_in customer
  end

  describe 'GET /cart' do
    it 'returns the cart with items' do
      get '/cart'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['cart_items'].length).to eq(1)
    end

    it 'returns empty message if cart is empty' do
      cart.cart_items.destroy_all
      get '/cart'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq("Cart is empty.")
    end
  end
end
