FactoryBot.define do
  factory :word_translation do
    association :word
    association :language
    meaning { "a meaning" }
    notes   { nil }
  end
end
