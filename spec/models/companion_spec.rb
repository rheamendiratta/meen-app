require "rails_helper"

RSpec.describe Companion, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:language) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:species) }
    it { is_expected.to validate_presence_of(:persona) }

    describe "language_id uniqueness" do
      subject { build(:companion) }

      it { is_expected.to validate_uniqueness_of(:language_id) }
    end
  end
end
