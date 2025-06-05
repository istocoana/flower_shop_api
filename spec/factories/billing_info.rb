FactoryBot.define do
  factory :billing_info do
    full_name { "John Doe" }
    address_line { "123 Main St" }
    city { "Bucharest" }
    zip { "123456" }
    country { "Romania" }
    country_code { "+40" }
    phone { "+40712345678" }
    association :user
  end
end
