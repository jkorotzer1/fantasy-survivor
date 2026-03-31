class Contestant < ApplicationRecord
  enum :status, active: 0, eliminated: 1, winner: 2

  serialize :previous_tribes, coder: JSON

  # Returns tribe name strings in order: past tribes first, current tribe last.
  # Handles both legacy plain-string entries and current {name,from,to} hash entries.
  def all_tribes
    prev_names = Array(previous_tribes).compact.map { |t| t.is_a?(Hash) ? t["name"].to_s : t.to_s }.reject(&:empty?)
    [*prev_names, tribe].compact.reject(&:empty?)
  end

  # Virtual attribute for the admin edit form.
  # Format per entry: "tribe_name:from_week:to_week"  (weeks optional)
  # e.g. "calo:1:3, vatu:4:6"
  def previous_tribes_input
    Array(previous_tribes).compact.map do |t|
      if t.is_a?(Hash)
        parts = [t["name"]]
        parts << t["from"] if t["from"].present?
        parts << t["to"]   if t["to"].present?
        parts.join(":")
      else
        t.to_s
      end
    end.join(", ")
  end

  def previous_tribes_input=(val)
    self.previous_tribes = val.to_s.split(",").map(&:strip).reject(&:empty?).map do |entry|
      parts = entry.split(":").map(&:strip)
      h = { "name" => parts[0].to_s }
      h["from"] = parts[1].to_i if parts[1].present?
      h["to"]   = parts[2].to_i if parts[2].present?
      h
    end
  end

  belongs_to :season

  has_many :scoring_events, dependent: :destroy
  has_many :weekly_picks, dependent: :destroy
  has_many :winner_picks, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 },
                   uniqueness: { scope: :season_id, case_sensitive: false }
  validates :season, presence: true

  def total_points_for_week(week)
    scoring_events.where(week: week).sum(&:point_value)
  end
end
