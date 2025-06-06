FactoryBot.define do
  factory :order do
    association :user
    billing_full_name { "John Doe" }
    billing_address_line { "123 Main St" }
    billing_city { "Bucharest" }
    billing_zip { "123456" }
    billing_country { "Romania" }
    billing_country_code { "+40" }
    billing_phone { "+40712345678" }
    total_price { 10.00 }
    status { "pending" }
  end
end
