class MessagePolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def destroy?
    user.admin? || record.user == user
  end

  def pin?
    user.admin?
  end
end
