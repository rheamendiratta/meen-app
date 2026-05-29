class DailyActivity < ApplicationRecord
  belongs_to :user
  belongs_to :language

  validates :activity_date, presence: true
  validates :activity_date, uniqueness: { scope: [:user_id, :language_id] }

  scope :completed, -> { where(module_completed: true) }
  scope :for_date, ->(date) { where(activity_date: date) }
  scope :ordered, -> { order(activity_date: :desc) }

  # Finalize the session: set module_completed and update streaks. Idempotent.
  def finalize!
    return if module_completed?

    update!(module_completed: true)
    update_streaks!
  end

  private

  def update_streaks!
    today = activity_date

    ul = user.user_languages.find_by(language: language)
    if ul.last_studied_on == today - 1
      ul.current_streak += 1
    elsif ul.last_studied_on != today
      ul.current_streak = 1
    end
    ul.longest_streak = [ul.current_streak, ul.longest_streak].max
    ul.last_studied_on = today
    ul.save!

    u = user
    if u.last_active_date == today - 1
      u.current_streak += 1
    elsif u.last_active_date != today
      u.current_streak = 1
    end
    u.longest_streak = [u.current_streak, u.longest_streak].max
    u.last_active_date = today
    u.save!
  end
end
