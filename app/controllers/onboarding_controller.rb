class OnboardingController < ApplicationController
  before_action :authenticate_user!

  def show
    @learnable_languages = Language.learnable.order(:name)
  end

  def update
    language = Language.learnable.find_by(id: params[:language_id])

    unless language
      redirect_to onboarding_path, alert: "Please choose a language to learn."
      return
    end

    english = Language.find_by(code: "en")

    current_user.update!(
      base_language: english,
      active_language: language
    )

    UserLanguage.find_or_create_by!(user: current_user, language: language) do |ul|
      ul.started_at = Time.current
    end

    redirect_to root_path, notice: "Welcome! Let's start learning #{language.name}."
  end
end
