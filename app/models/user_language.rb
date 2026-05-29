class UserLanguage < ApplicationRecord
  belongs_to :user
  belongs_to :language

  validates :user_id, uniqueness: { scope: :language_id }
  validates :started_at, presence: true
  validates :current_streak, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :longest_streak, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :words_introduced, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
