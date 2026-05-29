require "rails_helper"

RSpec.describe FsrsCard, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:word) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:card_type) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_numericality_of(:reps).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:lapses).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:scheduled_days).is_greater_than_or_equal_to(0) }

    describe "(user, word, card_type) uniqueness" do
      it "rejects a duplicate card" do
        existing = create(:fsrs_card)
        duplicate = build(:fsrs_card, user: existing.user, word: existing.word,
                                      card_type: existing.card_type)
        expect(duplicate).not_to be_valid
      end

      it "allows the same word with a different card_type" do
        existing = create(:fsrs_card, card_type: "recognition")
        different_type = build(:fsrs_card, user: existing.user, word: existing.word,
                                           card_type: "production")
        expect(different_type).to be_valid
      end
    end
  end

  describe "enum card_type" do
    it {
      is_expected.to define_enum_for(:card_type)
        .with_values(recognition: "recognition", production: "production")
        .backed_by_column_of_type(:string)
    }
  end

  describe "enum state (prefixed)" do
    it {
      is_expected.to define_enum_for(:state)
        .with_values(new: "new", learning: "learning", review: "review", relearning: "relearning")
        .with_prefix(:state)
        .backed_by_column_of_type(:string)
    }
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let(:word) { create(:word) }

    describe ".due" do
      it "returns cards with due_at in the past" do
        due_card = create(:fsrs_card, :due, user: user, word: word)
        create(:word, language: word.language)  # give another word for second card
        future_word = create(:word, language: word.language)
        future_card = create(:fsrs_card, user: user, word: future_word, due_at: 1.day.from_now, state: "review")
        expect(FsrsCard.due).to include(due_card)
        expect(FsrsCard.due).not_to include(future_card)
      end
    end
  end
end
