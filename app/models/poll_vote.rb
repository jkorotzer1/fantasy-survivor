class PollVote < ApplicationRecord
  belongs_to :user
  belongs_to :poll_option

  before_validation :set_message_id

  validates :message_id, presence: true
  validates :user_id, uniqueness: { scope: :message_id, message: "has already voted on this poll" }

  private

  def set_message_id
    self.message_id ||= poll_option&.message_id
  end
end
