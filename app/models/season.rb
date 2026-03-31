class Season < ApplicationRecord
  enum :status, upcoming: 0, active: 1, completed: 2

  has_many :contestants, dependent: :destroy
  has_many :weeks, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :users, through: :participations

  validates :name, presence: true, length: { maximum: 100 }
  validates :number, presence: true, numericality: { only_integer: true }, uniqueness: true
  validates :year, presence: true, numericality: { only_integer: true }

  def registration_open?
    week_one = weeks.find_by(number: 1)
    return true if week_one.nil?
    Time.current < week_one.picks_locked_at
  end

  def pre_merge_week?(n)
    merge_week.nil? || n < merge_week
  end

  def current_week
    weeks.where(scored: false).order(:number).first ||
      weeks.order(:number).last
  end

  # The week number to use when locking in a winner pick.
  # Advances as soon as each episode's pick-lock time passes (8 PM ET on air date),
  # independent of whether the admin has scored the week yet.
  def current_winner_pick_week
    weeks.where("picks_locked_at > ?", Time.current).order(:number).first ||
      weeks.order(:number).last
  end

  def buy_in_dollars
    buy_in_cents / 100.0
  end
end
