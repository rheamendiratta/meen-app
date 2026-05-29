FactoryBot.define do
  factory :user_vocabulary do
    association :user
    association :word
    association :language
    entry_source  { "curriculum" }
    introduced_on { Date.current }
  end
end
