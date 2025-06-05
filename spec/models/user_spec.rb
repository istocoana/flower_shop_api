require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe 'associations' do
    it { should have_many(:products).with_foreign_key(:created_by_id).dependent(:destroy) }
    it { should have_one(:cart).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
    it { should have_one(:billing_info).dependent(:destroy) }
    it { should accept_nested_attributes_for(:billing_info).allow_destroy(true) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value("email@example.com").for(:email) }

    it "validates password length if present" do
      user = build(:user, password: "toolongpassword")
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include("is too long (maximum is 8 characters)")
    end
  end

  describe "enums" do
    it "has correct role enum values" do
      expect(User.roles).to eq({ "admin" => "admin", "customer" => "customer" })
    end
  end
end
