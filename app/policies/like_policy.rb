class LikePolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def destroy?
    record.user == user
  end
end
