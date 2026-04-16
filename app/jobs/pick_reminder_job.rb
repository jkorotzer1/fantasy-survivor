class PickReminderJob < ApplicationJob
  queue_as :default

  # Track weeks we've already reminded so duplicate scheduler ticks don't send twice
  @@reminded_week_ids = Set.new

  def perform
    # Wide window — duplicate sends prevented by @@reminded_week_ids guard above
    window_start = 30.minutes.from_now
    window_end   = 3.hours.from_now

    weeks = Week.where(picks_locked_at: window_start..window_end)
    weeks.each do |week|
      next if @@reminded_week_ids.include?(week.id)
      @@reminded_week_ids << week.id

      week.season.participations.includes(:user).each do |participation|
        begin
          ParticipationMailer.pick_reminder(participation.user, week).deliver_now
          Rails.logger.info "[PickReminderJob] Sent reminder to #{participation.user.email} for Week #{week.number}"
        rescue => e
          Rails.logger.error "[PickReminderJob] Failed to send to #{participation.user.email}: #{e.class}: #{e.message}"
        end
      end
    end
  end
end
