class Language < ApplicationRecord
  has_one :companion, dependent: :destroy
  has_many :themes, dependent: :destroy
  has_many :words, dependent: :destroy
  has_many :word_translations, dependent: :destroy
  has_many :user_languages, dependent: :destroy
  has_many :users, through: :user_languages
  has_many :daily_activities, dependent: :destroy
  has_many :grammar_references, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :is_learnable, inclusion: { in: [true, false] }

  scope :learnable, -> { where(is_learnable: true) }
  scope :base_only, -> { where(is_learnable: false) }
end
