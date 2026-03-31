class AutoPickJob < ApplicationJob
  queue_as :default

  def perform
    # Find weeks that locked in the last 30 minutes (wider window guards against scheduler timing drift)
    window_start = 30.minutes.ago
    window_end   = Time.current

    Week.where(picks_locked_at: window_start..window_end).each do |week|
      week.season.participations
          .where(auto_pick: true)
          .includes(:user, :weekly_picks)
          .each do |participation|
            next if participation.weekly_picks.exists?(week: week)

            contestant = eligible_contestant(participation, week.season)
            next unless contestant

            pick = WeeklyPick.new(participation: participation, week: week, contestant: contestant)
            pick.save!(validate: false)
            Rails.logger.info "[AutoPick] #{participation.user.email} → #{contestant.name} (Week #{week.number})"
          end
    end
  end

  private

  def eligible_contestant(participation, season)
    used_twice = participation.contestants_used_twice
    season.contestants.active.where.not(id: used_twice).order(Arel.sql("RANDOM()")).first
  end
end
