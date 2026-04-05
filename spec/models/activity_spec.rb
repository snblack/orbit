require "rails_helper"

RSpec.describe Activity, type: :model do
  it "is invalid when planned and occurred_on is in the past" do
    activity = build(:activity, status: :planned, occurred_on: Date.yesterday)
    expect(activity).not_to be_valid
    expect(activity.errors[:occurred_on]).to include("должна быть сегодня или позже")
  end

  it "is valid when planned and occurred_on is today" do
    activity = build(:activity, status: :planned, occurred_on: Date.today)
    expect(activity).to be_valid
  end

  it "is valid when completed and occurred_on is in the past" do
    activity = build(:activity, status: :completed, occurred_on: Date.yesterday)
    expect(activity).to be_valid
  end
end
