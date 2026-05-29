require "rails_helper"

RSpec.describe Theme, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:language) }
    it { is_expected.to have_many(:words).dependent(:nullify) }
  end

  describe "validations" do
    subject { build(:theme) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:language_id) }
    it { is_expected.to validate_numericality_of(:display_order).is_greater_than_or_equal_to(0) }
  end

  describe "scopes" do
    describe ".ordered" do
      it "returns themes sorted by display_order" do
        lang = create(:language)
        t2 = create(:theme, language: lang, display_order: 2, name: "B")
        t1 = create(:theme, language: lang, display_order: 1, name: "A")
        expect(Theme.where(language: lang).ordered).to eq([t1, t2])
      end
    end
  end
end
