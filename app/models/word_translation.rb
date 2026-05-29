class WordTranslation < ApplicationRecord
  belongs_to :word
  belongs_to :language

  validates :meaning, presence: true
  validates :word_id, uniqueness: { scope: :language_id }
end
