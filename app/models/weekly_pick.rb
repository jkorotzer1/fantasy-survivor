class WeeklyPick < ApplicationRecord
  belongs_to :participation
  belongs_to :week
  belongs_to :contestant

  validates :participation_id, uniqueness: { scope: :week_id,
    message: "already has a pick for this week" }

  validate :week_not_locked
  validate :contestant_pick_limit
  validate :contestant_belongs_to_season
  validate :contestant_is_active

  delegate :season, to: :week

  private

  def week_not_locked
    return unless week&.locked?

    errors.add(:base, "Picks are locked for this week")
  end

  def contestant_pick_limit
    return unless participation && contestant

    existing = participation.weekly_picks.where(contestant: contestant)
    existing = existing.where.not(id: id) if persisted?

    if existing.count >= Participation::MAX_PICKS_PER_CONTESTANT
      errors.add(:contestant, "has already been picked the maximum number of times this season")
    end
  end

  def contestant_belongs_to_season
    return unless contestant && week

    unless contestant.season_id == week.season_id
      errors.add(:contestant, "does not belong to this season")
    end
  end

  def contestant_is_active
    return unless contestant

    unless contestant.active?
      errors.add(:contestant, "has been eliminated and cannot be picked")
    end
  end
end
