require "rails_helper"

RSpec.describe Language, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:is_learnable).in_array([true, false]) }

    describe "code uniqueness" do
      it "rejects duplicate codes" do
        create(:language, code: "xx", name: "Ex1")
        duplicate = build(:language, code: "xx", name: "Ex2")
        expect(duplicate).not_to be_valid
      end
    end
  end

  describe "associations" do
    it { is_expected.to have_one(:companion) }
    it { is_expected.to have_many(:themes) }
    it { is_expected.to have_many(:words) }
    it { is_expected.to have_many(:word_translations) }
    it { is_expected.to have_many(:user_languages) }
    it { is_expected.to have_many(:users).through(:user_languages) }
    it { is_expected.to have_many(:daily_activities) }
    it { is_expected.to have_many(:grammar_references) }
  end

  describe "scopes" do
    let!(:german)  { create(:language, :learnable, code: "de", name: "German") }
    let!(:english) { create(:language, code: "en",  name: "English") }

    describe ".learnable" do
      it "returns only learnable languages" do
        expect(Language.learnable).to contain_exactly(german)
      end
    end

    describe ".base_only" do
      it "returns only non-learnable languages" do
        expect(Language.base_only).to contain_exactly(english)
      end
    end
  end
end
