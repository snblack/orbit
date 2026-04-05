class Pod < ApplicationRecord
  has_many :pod_memberships, dependent: :destroy
  has_many :users, through: :pod_memberships
  has_many :notifications, dependent: :destroy
  has_many :activities, dependent: :destroy

  enum :status, { inactive: "inactive", active: "active" }

  validates :status, presence: true
end
