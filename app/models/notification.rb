class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :pod

  validates :message, presence: true
end
