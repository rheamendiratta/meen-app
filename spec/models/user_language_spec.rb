require "rails_helper"

RSpec.describe UserLanguage, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:language) }
  end

  describe "validations" do
    subject { build(:user_language) }

    it { is_expected.to validate_presence_of(:started_at) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:language_id) }
    it { is_expected.to validate_numericality_of(:current_streak).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:longest_streak).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:words_introduced).is_greater_than_or_equal_to(0) }
  end
end
