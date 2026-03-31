class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :season

  has_many :weekly_picks, dependent: :destroy
  has_many :winner_picks, dependent: :destroy

  validates :user_id, uniqueness: { scope: :season_id, message: "is already participating in this season" }

  MAX_PICKS_PER_CONTESTANT = 2

  def picks_remaining_for(contestant)
    MAX_PICKS_PER_CONTESTANT - weekly_picks.where(contestant: contestant).count
  end

  def can_pick?(contestant)
    picks_remaining_for(contestant) > 0
  end

  def has_winner_pick?
    winner_picks.exists?
  end

  def contestants_used_twice
    weekly_picks.group(:contestant_id)
                .having("COUNT(*) >= #{MAX_PICKS_PER_CONTESTANT}")
                .pluck(:contestant_id)
  end
end
