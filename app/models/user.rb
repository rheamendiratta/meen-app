# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  current_streak         :integer          default(0), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_active_date       :date
#  longest_streak         :integer          default(0), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  active_language_id     :integer
#  base_language_id       :integer
#
# Indexes
#
#  index_users_on_active_language_id    (active_language_id)
#  index_users_on_base_language_id      (base_language_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (active_language_id => languages.id)
#  fk_rails_...  (base_language_id => languages.id)
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :base_language, class_name: "Language", optional: true
  belongs_to :active_language, class_name: "Language", optional: true

  has_many :user_languages, dependent: :destroy
  has_many :enrolled_languages, through: :user_languages, source: :language

  has_many :user_vocabularies, dependent: :destroy
  has_many :known_words, through: :user_vocabularies, source: :word

  has_many :fsrs_cards, dependent: :destroy
  has_many :daily_activities, dependent: :destroy

  # Words the user has added privately.
  has_many :owned_words, class_name: "Word", foreign_key: :owner_user_id, dependent: :destroy

  validates :current_streak, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :longest_streak, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
