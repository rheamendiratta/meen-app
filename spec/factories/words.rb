FactoryBot.define do
  factory :word do
    association :language
    sequence(:lemma) { |n| "word#{n}" }
    word_type     { "word" }
    part_of_speech { "noun" }
    level         { "A1" }
    frequency_rank { nil }
    owner_user_id  { nil }

    trait :phrase do
      word_type { "phrase" }
    end

    trait :curated do
      owner_user_id { nil }
    end

    trait :user_added do
      association :owner_user, factory: :user
    end
  end
end
