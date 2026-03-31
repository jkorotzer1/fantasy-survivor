class PollOption < ApplicationRecord
  belongs_to :message
  has_many :poll_votes, dependent: :destroy

  validates :label, presence: true, length: { maximum: 200 }
end
