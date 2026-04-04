class PodMembership < ApplicationRecord
  belongs_to :pod
  belongs_to :user

  validates :pod_id, uniqueness: { scope: :user_id }
end
