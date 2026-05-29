class UserVocabulary < ApplicationRecord
  self.table_name = "user_vocabulary"

  belongs_to :user
  belongs_to :word
  belongs_to :language

  enum :entry_source, { curriculum: "curriculum", user_added: "user_added" }, validate: true

  validates :entry_source, presence: true
  validates :user_id, uniqueness: { scope: :word_id }

  after_create :create_fsrs_cards

  private

  def create_fsrs_cards
    [:recognition, :production].each do |card_type|
      FsrsCard.find_or_create_by!(user: user, word: word, card_type: card_type) do |card|
        card.state          = "new"
        card.reps           = 0
        card.lapses         = 0
        card.scheduled_days = 0
        card.due_at         = Time.current
      end
    end
  end
end
