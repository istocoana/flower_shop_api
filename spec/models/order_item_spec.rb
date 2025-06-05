require "rails_helper"

RSpec.describe OrderItem, type: :model do
  describe "associations" do
    it { should belong_to(:order) }
    it { should belong_to(:product) }
  end

  describe "validations" do
    subject { create(:order_item) }

    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_uniqueness_of(:product_id).scoped_to(:order_id) }
  end
end
