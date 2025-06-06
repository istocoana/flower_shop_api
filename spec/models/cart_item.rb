require "rails_helper"

RSpec.describe CartItem, type: :model do
  describe "associations" do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end

  describe "validations" do
    subject { create(:cart_item) }

    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it {
      should validate_uniqueness_of(:product_id).scoped_to(:cart_id)
        .with_message("is already in cart")
    }

    context "custom validation: quantity_does_not_exceed_stock" do
      let(:product) { create(:product, stock: 5) }
      let(:cart) { create(:cart) }

      it "adds an error if quantity exceeds stock" do
        item = described_class.new(cart: cart, product: product, quantity: 10)
        item.valid?
        expect(item.errors[:quantity]).to include("exceeds available stock (5)")
      end

      it "is valid if quantity is within stock" do
        item = described_class.new(cart: cart, product: product, quantity: 3)
        expect(item).to be_valid
      end
    end
  end
end
