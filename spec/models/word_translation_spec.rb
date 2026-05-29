require "rails_helper"

RSpec.describe WordTranslation, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:word) }
    it { is_expected.to belong_to(:language) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:meaning) }

    describe "word_id uniqueness within language" do
      it "rejects a second translation for the same word+language pair" do
        existing = create(:word_translation)
        duplicate = build(:word_translation, word: existing.word, language: existing.language)
        expect(duplicate).not_to be_valid
      end
    end
  end
end
