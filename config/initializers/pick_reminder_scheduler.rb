# Runs every 15 minutes to:
#   1. Send pick reminder emails for weeks locking in ~1 hour
#   2. Auto-pick for opted-in participants after picks lock
#   3. Scrape POTW results from Google Sheets (once per day)
if Rails.env.production?
  Thread.new do
    Rails.application.executor.wrap do
      loop do
        sleep 15.minutes
        begin
          PickReminderJob.perform_now
        rescue => e
          Rails.logger.error "[PickReminderJob] #{e.class}: #{e.message}"
        end
        begin
          AutoPickJob.perform_now
        rescue => e
          Rails.logger.error "[AutoPickJob] #{e.class}: #{e.message}"
        end
        begin
          PotwScraperJob.perform_now
        rescue => e
          Rails.logger.error "[PotwScraperJob] #{e.class}: #{e.message}"
        end
      end
    end
  end
end
