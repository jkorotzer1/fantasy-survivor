class SeasonPolicy < ApplicationPolicy
  def index?  = true
  def show?   = true

  def standings? = true
  def scores?    = true
  def my_picks?  = user.present?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
