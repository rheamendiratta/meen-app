require "rails_helper"

RSpec.describe WordForm, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:word) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:form_text) }
  end

  describe "scopes" do
    describe ".primary" do
      it "returns only primary forms" do
        word = create(:word)
        primary = create(:word_form, word: word, is_primary: true)
        secondary = create(:word_form, word: word, is_primary: false, form_text: "other")
        expect(WordForm.where(word: word).primary).to contain_exactly(primary)
        expect(WordForm.where(word: word).primary).not_to include(secondary)
      end
    end
  end
end
