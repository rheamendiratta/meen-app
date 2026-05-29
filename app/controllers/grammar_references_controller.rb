class GrammarReferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_active_language

  def index
    @categories = GrammarReference
      .where(language: @language)
      .ordered
      .group_by(&:category)
  end

  private

  def set_active_language
    @language = current_user.active_language
  end
end
