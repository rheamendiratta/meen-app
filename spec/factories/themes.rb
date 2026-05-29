FactoryBot.define do
  factory :theme do
    association :language
    sequence(:name) { |n| "Theme #{n}" }
    display_order { 0 }
  end
end
