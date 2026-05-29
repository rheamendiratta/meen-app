FactoryBot.define do
  factory :user_language do
    association :user
    association :language
    current_streak  { 0 }
    longest_streak  { 0 }
    words_introduced { 0 }
    started_at      { Time.current }
  end
end
