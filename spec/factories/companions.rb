FactoryBot.define do
  factory :companion do
    association :language
    name    { "Greta" }
    species { "fox" }
    persona { "Warm and playful German tutor." }
  end
end
