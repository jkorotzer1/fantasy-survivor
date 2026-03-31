class Message < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: :parent_id, dependent: :destroy
  has_many :poll_options, dependent: :destroy
  has_many :poll_votes, through: :poll_options

  accepts_nested_attributes_for :poll_options, reject_if: :all_blank

  validates :body, presence: true, length: { maximum: 1000 }

  scope :top_level,    -> { where(parent_id: nil) }
  scope :pinned,       -> { where(pinned: true) }
  scope :not_pinned,   -> { where(pinned: false) }
  scope :chronological, -> { order(created_at: :desc) }

  def author_name
    anonymous? ? "Anonymous" : user.name
  end
end
