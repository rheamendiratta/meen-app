class Companion < ApplicationRecord
  belongs_to :language

  validates :name, presence: true
  validates :species, presence: true
  validates :persona, presence: true
  validates :language_id, uniqueness: true
end
