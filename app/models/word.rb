class Word < ApplicationRecord
  belongs_to :language
  belongs_to :theme, optional: true
  belongs_to :owner_user, class_name: "User", foreign_key: :owner_user_id, optional: true

  has_many :word_forms, dependent: :destroy
  has_many :word_translations, dependent: :destroy
  has_many :user_vocabularies, dependent: :destroy
  has_many :users, through: :user_vocabularies
  has_many :fsrs_cards, dependent: :destroy

  enum :word_type, { word: "word", phrase: "phrase" }, validate: true

  validates :lemma, presence: true,
                   uniqueness: { scope: [:language_id, :owner_user_id],
                                 message: "is already in your word bank for this language" }
  validates :word_type, presence: true
  validates :language_id, presence: true

  # Curriculum words only — owner_user_id IS NULL filter matches CLAUDE.md daily-5 query.
  scope :curated, -> { where(owner_user_id: nil) }
  scope :by_frequency, -> { where.not(frequency_rank: nil).order(:frequency_rank) }
  scope :for_language, ->(language) { where(language: language) }

  # Next N curriculum words for a user: frequency-ordered, not yet in their vocabulary.
  scope :next_for_user, ->(user, language, count: 5) {
    already_known = user.user_vocabularies.where(language: language).select(:word_id)
    for_language(language)
      .curated
      .by_frequency
      .where.not(id: already_known)
      .limit(count)
  }
end
