FactoryBot.define do
  factory :word_form do
    association :word
    sequence(:form_text) { |n| "form#{n}" }
    morphology { "lemma" }
    is_primary { true }
  end
end
