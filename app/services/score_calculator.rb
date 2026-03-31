class ScoreCalculator
  def self.total_score(participation)
    weekly_total(participation) + winner_pick_score(participation)
  end

  def self.weekly_total(participation)
    participation.weekly_picks.includes(:week, contestant: :scoring_events).sum do |pick|
      pick.contestant.scoring_events
          .select { |e| e.week_id == pick.week_id }
          .sum(&:point_value)
    end
  end

  def self.winner_pick_score(participation)
    participation.winner_picks.includes(:contestant).first&.awarded_points || 0
  end

  def self.season_standings(season)
    season.participations
          .includes(:user, :weekly_picks, :winner_picks, winner_picks: :contestant,
                    weekly_picks: { contestant: :scoring_events, week: {} })
          .map { |p| { participation: p, user: p.user, total: total_score(p) } }
          .sort_by { |r| -r[:total] }
  end

  def self.weekly_breakdown(participation)
    participation.weekly_picks
                 .includes(:week, contestant: :scoring_events)
                 .order("weeks.number")
                 .each_with_object({}) do |pick, memo|
      events = pick.contestant.scoring_events.select { |e| e.week_id == pick.week_id }
      memo[pick.week.number] = {
        contestant: pick.contestant.name,
        score: events.sum(&:point_value),
        events: events.map { |e| { type: e.event_type, label: e.label, points: e.point_value } }
      }
    end
  end
end
