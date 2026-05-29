require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:base_language).class_name("Language").optional }
    it { is_expected.to belong_to(:active_language).class_name("Language").optional }
    it { is_expected.to have_many(:user_languages).dependent(:destroy) }
    it { is_expected.to have_many(:enrolled_languages).through(:user_languages) }
    it { is_expected.to have_many(:user_vocabularies).dependent(:destroy) }
    it { is_expected.to have_many(:known_words).through(:user_vocabularies) }
    it { is_expected.to have_many(:fsrs_cards).dependent(:destroy) }
    it { is_expected.to have_many(:daily_activities).dependent(:destroy) }
    it { is_expected.to have_many(:owned_words).class_name("Word").dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:current_streak).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:longest_streak).is_greater_than_or_equal_to(0) }
  end

  describe "Devise" do
    it "is invalid without an email" do
      user = build(:user, email: "")
      expect(user).not_to be_valid
    end

    it "is invalid with a duplicate email" do
      create(:user, email: "dup@example.com")
      expect(build(:user, email: "dup@example.com")).not_to be_valid
    end
  end
end
