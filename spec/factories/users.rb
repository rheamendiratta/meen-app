FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password              { "password123" }
    password_confirmation { "password123" }
    current_streak        { 0 }
    longest_streak        { 0 }
  end
end
