class WinnerPickPolicy < ApplicationPolicy
  def new?    = player_without_winner_pick?
  def create? = player_without_winner_pick?

  private

  def player_without_winner_pick?
    return false unless user

    participation = record.is_a?(WinnerPick) ? record.participation : record
    participation&.user_id == user.id && !participation&.has_winner_pick?
  end
end
