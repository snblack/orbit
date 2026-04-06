require "rails_helper"

RSpec.describe Message, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:message)).to be_valid
    end

    it "is invalid without body" do
      expect(build(:message, body: nil)).not_to be_valid
    end

    it "is invalid with blank body" do
      expect(build(:message, body: "")).not_to be_valid
    end

    it "is invalid when body exceeds 1000 characters" do
      expect(build(:message, body: "a" * 1001)).not_to be_valid
    end

    it "is valid when body is exactly 1000 characters" do
      expect(build(:message, body: "a" * 1000)).to be_valid
    end

    it "is invalid without pod" do
      expect(build(:message, pod: nil)).not_to be_valid
    end

    it "is invalid without user" do
      expect(build(:message, user: nil)).not_to be_valid
    end
  end
end
