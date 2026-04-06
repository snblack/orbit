class Message < ApplicationRecord
  belongs_to :pod
  belongs_to :user

  validates :body, presence: true, length: { maximum: 1000 }
end
