class ScoringEventType < ApplicationRecord
  validates :key,    presence: true, uniqueness: true,
                     format: { with: /\A[a-z0-9_]+\z/, message: "only lowercase letters, numbers, and underscores" }
  validates :label,  presence: true
  validates :points, presence: true, numericality: { only_integer: true }

  scope :ordered, -> { order(:label) }

  def points_display
    points >= 0 ? "+#{points}" : points.to_s
  end
end
