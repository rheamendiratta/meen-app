require "rails_helper"

RSpec.describe GrammarReference, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:language) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_numericality_of(:display_order).is_greater_than_or_equal_to(0) }
  end

  describe "scopes" do
    let(:lang) { create(:language) }

    describe ".for_category" do
      it "filters by category" do
        noun_ref = create(:grammar_reference, language: lang, category: "nouns")
        verb_ref = create(:grammar_reference, language: lang, category: "verbs")
        expect(GrammarReference.for_category("nouns")).to contain_exactly(noun_ref)
        expect(GrammarReference.for_category("nouns")).not_to include(verb_ref)
      end
    end

    describe ".ordered" do
      it "returns in display_order ascending" do
        r2 = create(:grammar_reference, language: lang, display_order: 2, title: "B")
        r1 = create(:grammar_reference, language: lang, display_order: 1, title: "A")
        expect(GrammarReference.where(language: lang).ordered).to eq([r1, r2])
      end
    end
  end
end
