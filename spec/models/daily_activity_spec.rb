require "rails_helper"

RSpec.describe DailyActivity, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:language) }
  end

  describe "validations" do
    subject { build(:daily_activity) }

    it { is_expected.to validate_presence_of(:activity_date) }
    it { is_expected.to validate_uniqueness_of(:activity_date).scoped_to(%i[user_id language_id]) }
  end

  describe "scopes" do
    let(:user)     { create(:user) }
    let(:language) { create(:language) }

    describe ".completed" do
      it "returns only completed activities" do
        done = create(:daily_activity, :completed, user: user, language: language)
        pending_activity = create(:daily_activity, user: user, language: language, activity_date: 1.day.ago)
        expect(DailyActivity.completed).to include(done)
        expect(DailyActivity.completed).not_to include(pending_activity)
      end
    end

    describe ".for_date" do
      it "filters by activity_date" do
        today = create(:daily_activity, user: user, language: language, activity_date: Date.current)
        yesterday = create(:daily_activity, user: user, language: language, activity_date: 1.day.ago)
        expect(DailyActivity.for_date(Date.current)).to contain_exactly(today)
        expect(DailyActivity.for_date(Date.current)).not_to include(yesterday)
      end
    end
  end
end
