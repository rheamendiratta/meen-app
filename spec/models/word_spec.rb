require "rails_helper"

RSpec.describe Word, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:language) }
    it { is_expected.to belong_to(:theme).optional }
    it { is_expected.to belong_to(:owner_user).class_name("User").optional }
    it { is_expected.to have_many(:word_forms).dependent(:destroy) }
    it { is_expected.to have_many(:word_translations).dependent(:destroy) }
    it { is_expected.to have_many(:user_vocabularies).dependent(:destroy) }
    it { is_expected.to have_many(:fsrs_cards).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:lemma) }
    it { is_expected.to validate_presence_of(:word_type) }
    it { is_expected.to validate_presence_of(:language_id) }
  end

  describe "enum word_type" do
    it {
      is_expected.to define_enum_for(:word_type)
        .with_values(word: "word", phrase: "phrase")
        .backed_by_column_of_type(:string)
    }

    it "is invalid with an unknown word_type" do
      word = build(:word)
      word.word_type = nil
      expect(word).not_to be_valid
    end
  end

  describe "scopes" do
    let(:lang) { create(:language, :learnable) }

    describe ".curated" do
      it "returns words with no owner" do
        curated = create(:word, language: lang, owner_user_id: nil)
        user_word = create(:word, :user_added, language: lang)
        expect(Word.curated).to include(curated)
        expect(Word.curated).not_to include(user_word)
      end
    end

    describe ".by_frequency" do
      it "orders by frequency_rank ascending, excluding nulls" do
        w1 = create(:word, language: lang, frequency_rank: 10)
        w2 = create(:word, language: lang, frequency_rank: 1)
        _nil_rank = create(:word, language: lang, frequency_rank: nil)
        expect(Word.where(language: lang).by_frequency.to_a).to eq([w2, w1])
      end
    end

    describe ".for_language" do
      it "returns words for the given language" do
        other_lang = create(:language)
        w = create(:word, language: lang)
        create(:word, language: other_lang)
        expect(Word.for_language(lang)).to contain_exactly(w)
      end
    end
  end
end
