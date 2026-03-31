class WeeklyPickPolicy < ApplicationPolicy
  def new?    = own_pick?
  def create? = own_pick?
  def update? = own_pick?
  def destroy? = own_pick?

  private

  def own_pick?
    return false unless user

    # For persisted picks, verify ownership. For new unsaved picks the
    # controller already confirms participation belongs to current_user.
    if record.is_a?(WeeklyPick) && record.persisted?
      record.participation.user_id == user.id
    else
      true
    end
  end
end
