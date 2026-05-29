class FsrsCard < ApplicationRecord
  belongs_to :user
  belongs_to :word

  # _prefix avoids collision between the "new" state value and FsrsCard.new (constructor).
  enum :card_type, { recognition: "recognition", production: "production" }, validate: true
  enum :state, { new: "new", learning: "learning", review: "review", relearning: "relearning" },
       prefix: :state, validate: true

  validates :card_type, presence: true
  validates :state, presence: true
  validates :user_id, uniqueness: { scope: [:word_id, :card_type] }
  validates :reps, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :lapses, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :scheduled_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :due, -> { where(due_at: ..Time.current) }
  scope :for_review, -> { where(state: ["learning", "review", "relearning"]) }
end
