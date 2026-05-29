require "rails_helper"

RSpec.describe UserVocabulary, type: :model do
  describe "table name" do
    it { expect(described_class.table_name).to eq("user_vocabulary") }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:word) }
    it { is_expected.to belong_to(:language) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:entry_source) }

    describe "user_id uniqueness within word scope" do
      it "rejects a duplicate (user, word) pair" do
        existing = create(:user_vocabulary)
        duplicate = build(:user_vocabulary, user: existing.user, word: existing.word,
                                            language: existing.language)
        expect(duplicate).not_to be_valid
      end
    end
  end

  describe "enum entry_source" do
    it {
      is_expected.to define_enum_for(:entry_source)
        .with_values(curriculum: "curriculum", user_added: "user_added")
        .backed_by_column_of_type(:string)
    }
  end
end
