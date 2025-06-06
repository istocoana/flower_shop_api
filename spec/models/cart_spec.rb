require "rails_helper"

RSpec.describe Cart, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:products).through(:cart_items) }
  end

  describe "validations" do
    subject { create(:cart) }
    it { should validate_uniqueness_of(:user_id) }
  end
end
