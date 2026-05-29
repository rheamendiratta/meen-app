FactoryBot.define do
  factory :daily_activity do
    association :user
    association :language
    activity_date       { Date.current }
    module_completed    { false }
    new_words_introduced { 0 }
    cards_reviewed      { 0 }
    flashcards_done     { 0 }
    speaking_done       { 0 }
    listening_done      { 0 }
    reading_done        { 0 }

    trait :completed do
      module_completed    { true }
      new_words_introduced { 5 }
      cards_reviewed      { 20 }
      flashcards_done     { 1 }
      speaking_done       { 1 }
      listening_done      { 1 }
      reading_done        { 1 }
    end
  end
end
