require "net/http"
require "uri"
require "csv"

class PotwScraperJob < ApplicationJob
  queue_as :default

  # Public Google Sheets CSV export for Season 50 POTW tracker.
  # Update this URL at the start of each new season.
  POTW_SHEET_URL = "https://docs.google.com/spreadsheets/d/e/" \
    "2PACX-1vRq3wLRkvl8RH3n1egpSub2keTJtsue9G6Je59EKRuQrbyCTRofc8ZJjD-mmbxx4z8_nYc5dqox3vc3" \
    "/pub?output=csv&gid=866303818"

  # Only run once per calendar day — the scheduler fires every 15 min.
  @@last_run_date = nil

  def perform
    today = Date.current
    if @@last_run_date == today
      Rails.logger.info "[PotwScraperJob] Already ran today — skipping"
      return
    end
    @@last_run_date = today

    season = Season.last
    unless season
      Rails.logger.info "[PotwScraperJob] No season found — skipping"
      return
    end

    # Find the most recent locked week (within the past 7 days) that has no POTW events yet.
    week = season.weeks
                 .where("picks_locked_at < ?", Time.current)
                 .where("picks_locked_at > ?", 7.days.ago)
                 .order(picks_locked_at: :desc)
                 .find { |w| w.scoring_events.where(event_type: "potw_top3").none? }

    unless week
      Rails.logger.info "[PotwScraperJob] No qualifying week found (all recent weeks already have POTW events or none locked) — skipping"
      return
    end

    Rails.logger.info "[PotwScraperJob] Processing Week #{week.number} (#{season.name})"

    csv_body = fetch_csv(POTW_SHEET_URL)
    unless csv_body
      Rails.logger.error "[PotwScraperJob] Failed to fetch POTW sheet"
      return
    end

    top3 = parse_top3(csv_body, week.number)
    if top3.empty?
      Rails.logger.warn "[PotwScraperJob] No POTW data found for Episode #{week.number} yet — will retry tomorrow"
      @@last_run_date = nil  # allow retry tomorrow
      return
    end

    Rails.logger.info "[PotwScraperJob] Episode #{week.number} top #{top3.length}: #{top3.map { |r| "#{r[:name]} (#{r[:votes]})" }.join(", ")}"

    contestants = season.contestants.to_a
    saved_names = []

    top3.each do |entry|
      contestant = match_contestant(entry[:name], contestants)
      unless contestant
        Rails.logger.warn "[PotwScraperJob] Could not match '#{entry[:name]}' to any contestant — skipping"
        next
      end

      # Idempotent: skip if event already exists
      next if week.scoring_events.exists?(contestant: contestant, event_type: "potw_top3")

      week.scoring_events.create!(
        contestant: contestant,
        event_type: "potw_top3",
        notes:      "POTW rank #{entry[:rank]} — auto-imported"
      )
      saved_names << contestant.name
    end

    if saved_names.any?
      Rails.logger.info "[PotwScraperJob] Saved potw_top3 for: #{saved_names.join(", ")}"
      week.update!(scored: true)
      Rails.logger.info "[PotwScraperJob] Week #{week.number} marked as scored"
    else
      Rails.logger.warn "[PotwScraperJob] No events saved (all contestants unmatched or already present)"
    end
  end

  private

  def fetch_csv(url, redirects_left = 5)
    return nil if redirects_left == 0

    uri  = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = true
    http.open_timeout = 10
    http.read_timeout = 10

    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = "Mozilla/5.0 (compatible; fantasy-survivor-potw/1.0)"

    res = http.request(req)

    case res.code
    when "200"
      res.body
    when "301", "302", "303", "307", "308"
      fetch_csv(res["Location"], redirects_left - 1)
    else
      Rails.logger.error "[PotwScraperJob] HTTP #{res.code} fetching sheet"
      nil
    end
  rescue => e
    Rails.logger.error "[PotwScraperJob] fetch_csv failed: #{e.message}"
    nil
  end

  # Sheet layout:
  #   col 0: blank
  #   col 1: contestant first name
  #   col 2+: vote counts by episode ("Episode 1", "Episode 2", ...)
  #
  # Returns array of { name:, votes:, rank: } for all contestants whose
  # rank is 1, 2, or 3 (ties included).
  def parse_top3(csv_body, week_number)
    rows   = CSV.parse(csv_body)
    header = rows[0]

    ep_col = header.index("Episode #{week_number}")
    return [] unless ep_col

    entries = rows[1..].map do |row|
      name  = row[1].to_s.strip
      votes = row[ep_col].to_s.strip
      next nil if name.empty? || votes.empty?
      { name: name, votes: votes.to_i }
    end.compact

    return [] if entries.empty?

    # Sort descending and assign dense ranks
    sorted      = entries.sort_by { |e| -e[:votes] }
    current_rank = 0
    prev_votes   = nil

    ranked = sorted.map do |e|
      if e[:votes] != prev_votes
        current_rank += 1
        prev_votes    = e[:votes]
      end
      e.merge(rank: current_rank)
    end

    ranked.select { |e| e[:rank] <= 3 }
  end

  # Match by exact full name, case-insensitive full name, first name, or
  # nickname (any word inside quotes, e.g. "Q" from 'Quintavius "Q" Burdette').
  def match_contestant(name, contestants)
    downcased = name.downcase
    contestants.find { |c| c.name == name } ||
      contestants.find { |c| c.name.downcase == downcased } ||
      contestants.find { |c| c.name.split.first.downcase == downcased } ||
      contestants.find { |c| c.name.scan(/"([^"]+)"/).flatten.any? { |nick| nick.downcase == downcased } }
  end
end
