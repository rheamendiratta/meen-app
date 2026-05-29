class Theme < ApplicationRecord
  belongs_to :language
  has_many :words, dependent: :nullify

  validates :name, presence: true
  validates :name, uniqueness: { scope: :language_id }
  validates :display_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:display_order) }
end
