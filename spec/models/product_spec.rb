require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:user) { create(:user) }

  describe "associations" do
    it { should belong_to(:created_by).class_name("User") }
    it { should have_many_attached(:images) }
  end

  describe "validations" do
    subject { create(:product, created_by: user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:price) }

    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_uniqueness_of(:description).case_insensitive }

    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:stock).is_greater_than_or_equal_to(0).only_integer.allow_nil }
  end

  describe "enums" do
     it "has correct currency enum values" do
      expect(Product.currencies).to eq({ "ron" => "ron", "eur" => "eur", "usd" => "usd" })
    end

    it "has correct status values" do
      expect(Product.statuses).to eq({ "active" => "active", "inactive" => "inactive" })
    end
  end
end
