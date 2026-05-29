class WordForm < ApplicationRecord
  belongs_to :word

  validates :form_text, presence: true

  scope :primary, -> { where(is_primary: true) }
end
