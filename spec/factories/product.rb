FactoryBot.define do
  factory :product do
    association :created_by, factory: :user
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 10.0..100.0) }
    stock { rand(1..50) }
    currency { "ron" }
    status { "active" }

    after(:build) do |product|
      product.images.attach(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "flower.jpeg")),
        filename: "flower.jpeg",
        content_type: "image/jpeg"
      )
    end
  end
end
