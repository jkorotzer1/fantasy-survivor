class PollVotePolicy < ApplicationPolicy
  def create?
    user.present?
  end
end
