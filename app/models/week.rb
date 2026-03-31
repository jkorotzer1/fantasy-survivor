class Week < ApplicationRecord
  belongs_to :season

  has_many :weekly_picks, dependent: :destroy
  has_many :scoring_events, dependent: :destroy

  validates :number, presence: true, numericality: { only_integer: true },
                     uniqueness: { scope: :season_id }
  validates :air_date, presence: true
  validates :picks_locked_at, presence: true

  before_validation :set_picks_locked_at_from_air_date, if: :air_date?

  scope :ordered, -> { order(:number) }
  scope :scored, -> { where(scored: true) }

  def locked?
    Time.current >= picks_locked_at
  end

  def post_merge?
    season.merge_week.present? && number >= season.merge_week
  end

  def picks_open?
    !locked?
  end

  def display_name
    "Week #{number}"
  end

  private

  def set_picks_locked_at_from_air_date
    self.picks_locked_at = Time.use_zone("Eastern Time (US & Canada)") do
      Time.zone.local(air_date.year, air_date.month, air_date.day, 20, 0, 0)
    end
  end
end
