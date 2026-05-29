class ApplicationController < ActionController::Base
  before_action :redirect_if_onboarding_incomplete

  helper_method :turbo_native_app?

  private

  def turbo_native_app?
    request.user_agent.to_s.include?("Turbo Native")
  end

  def redirect_if_onboarding_incomplete
    return unless user_signed_in?
    return if current_user.active_language_id.present?
    return if devise_controller?
    return if controller_name == "onboarding"

    redirect_to onboarding_path
  end
end
