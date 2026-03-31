class WinnerPick < ApplicationRecord
  POINTS_BY_WEEK = {
    1 => 40, 2 => 36, 3 => 33, 4 => 30, 5 => 27,
    6 => 20, 7 => 15, 8 => 13, 9 => 12, 10 => 9,
    11 => 7, 12 => 5, 13 => 0
  }.freeze

  belongs_to :participation
  belongs_to :contestant

  validates :participation_id, uniqueness: { message: "already has a winner pick for this season" }
  validates :week_locked, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def correct?
    contestant.winner?
  end

  def points_if_correct
    POINTS_BY_WEEK.fetch(week_locked, 0)
  end

  def awarded_points
    correct? ? points_if_correct : 0
  end
end
