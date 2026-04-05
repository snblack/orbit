require "rails_helper"

RSpec.describe User, type: :model do
  describe "display_name validation" do
    it "is valid without display_name in default context" do
      expect(build(:user, display_name: nil)).to be_valid
    end

    it "is invalid without display_name in onboarding_profile context" do
      user = build(:user, display_name: nil)
      expect(user.valid?(:onboarding_profile)).to be false
      expect(user.errors[:display_name]).to be_present
    end

    it "is valid with display_name in onboarding_profile context" do
      expect(build(:user, display_name: "Alice").valid?(:onboarding_profile)).to be true
    end
  end

  describe "bio validation" do
    it "is invalid when bio exceeds 300 characters" do
      user = build(:user, bio: "x" * 301)
      expect(user).not_to be_valid
      expect(user.errors[:bio]).to be_present
    end

    it "is valid when bio is exactly 300 characters" do
      expect(build(:user, bio: "x" * 300)).to be_valid
    end
  end
end
