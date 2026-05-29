class GrammarReference < ApplicationRecord
  belongs_to :language

  validates :title, presence: true
  validates :category, presence: true
  validates :content, presence: true
  validates :display_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :for_category, ->(category) { where(category: category) }
  scope :ordered, -> { order(:display_order) }
end
