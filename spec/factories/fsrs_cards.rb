FactoryBot.define do
  factory :fsrs_card do
    association :user
    association :word
    card_type      { "recognition" }
    state          { "new" }
    reps           { 0 }
    lapses         { 0 }
    scheduled_days { 0 }
    stability      { nil }
    difficulty     { nil }
    due_at         { nil }
    last_reviewed_at { nil }

    trait :production do
      card_type { "production" }
    end

    trait :due do
      due_at { 1.hour.ago }
      state  { "review" }
    end
  end
end
