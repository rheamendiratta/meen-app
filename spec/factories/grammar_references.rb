FactoryBot.define do
  factory :grammar_reference do
    association :language
    sequence(:title)    { |n| "Grammar Rule #{n}" }
    category            { "nouns" }
    content             { "Some grammar content." }
    display_order       { 0 }
  end
end
