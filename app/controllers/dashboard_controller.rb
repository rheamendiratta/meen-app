class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @language      = current_user.active_language
    @companion     = @language.companion
    @user_language = current_user.user_languages.find_by(language: @language)
    @today         = DailyActivity.find_or_initialize_by(
      user: current_user,
      language: @language,
      activity_date: Date.current
    )
    @words_known   = current_user.user_vocabularies.where(language: @language).count
  end
end
