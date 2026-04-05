class Activity < ApplicationRecord
  belongs_to :pod
  belongs_to :proposed_by, class_name: "User", foreign_key: :proposed_by_id

  enum :status, { completed: "completed", planned: "planned" }

  validates :occurred_on, presence: true
  validates :status, presence: true
  validate :occurred_on_not_in_past, on: :create, if: :planned?

  private

  def occurred_on_not_in_past
    return if occurred_on.blank?
    errors.add(:occurred_on, :past_date) if occurred_on < Date.today
  end
end
