require "rails_helper"

RSpec.describe Order, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:order_items).dependent(:destroy) }
    it { should have_many(:products).through(:order_items) }
  end

  describe "validations" do
    subject { create(:order) }

    it "has correct enum values" do
      expect(Order.statuses).to eq({
        "pending" => "pending",
        "confirmed" => "confirmed",
        "shipped" => "shipped",
        "delivered" => "delivered",
        "cancelled" => "cancelled"
      })
    end

    it { should validate_numericality_of(:total_price).is_greater_than_or_equal_to(0) }
  end

  describe "callbacks" do
    let(:product) { create(:product, stock: 5) }
    let(:order) do
      create(:order, status: "pending").tap do |o|
        o.order_items.create!(product: product, quantity: 2, price: product.price)
      end
    end

    it "does not restore stock if status not changed to cancelled" do
      expect {
        order.update!(status: "confirmed")
        product.reload
      }.not_to change(product, :stock)
    end
  end
end
