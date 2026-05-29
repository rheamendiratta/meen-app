FactoryBot.define do
  factory :language do
    sequence(:code) { |n| "l#{n}" }
    sequence(:name) { |n| "Language #{n}" }
    is_learnable { false }

    trait :learnable do
      is_learnable { true }
    end

    factory :german,  class: "Language" do
      code { "de" }
      name { "German" }
      is_learnable { true }
    end

    factory :french,  class: "Language" do
      code { "fr" }
      name { "French" }
      is_learnable { true }
    end

    factory :english, class: "Language" do
      code { "en" }
      name { "English" }
      is_learnable { false }
    end
  end
end
