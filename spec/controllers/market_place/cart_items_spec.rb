require 'rails_helper'

RSpec.describe 'MarketPlace::CartItemsController', type: :request do
  let(:customer) { create(:user, role: :customer) }
  let!(:cart) { create(:cart, user: customer) }
  let!(:product) { create(:product, stock: 5) }

  before do
    sign_in customer
  end

  describe 'POST /cart_items' do
    it 'adds a new product to the cart' do
      post '/cart_items', params: { product_id: product.id, quantity: 2 }
      expect(response).to have_http_status(:created)
    end

    it 'returns error when quantity exceeds stock' do
      post '/cart_items', params: { product_id: product.id, quantity: 10 }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /cart_items/:product_id' do
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

    it 'updates quantity if valid' do
      patch "/cart_items/#{product.id}", params: { quantity: 3 }
      expect(response).to have_http_status(:ok)
      expect(cart_item.reload.quantity).to eq(3)
    end

    it 'removes item if quantity is less than 1' do
      patch "/cart_items/#{product.id}", params: { quantity: 0 }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /cart_items/:product_id' do
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

    it 'removes item from cart' do
      delete "/cart_items/#{product.id}"
      expect(response).to have_http_status(:ok)
      expect(cart.cart_items.find_by(product_id: product.id)).to be_nil
    end
  end
end
