# ── Admin user ────────────────────────────────────────────────────────────────
admin = User.find_or_create_by!(email: "jkorotzer@wustl.edu") do |u|
  u.name     = "Jared"
  u.password = ENV.fetch("ADMIN_PASSWORD", "changeme123!")
  u.role     = :admin
end
admin.update!(role: :admin) unless admin.admin?
puts "Admin: #{admin.email}"

# ── Season 50 ─────────────────────────────────────────────────────────────────
season50 = Season.find_or_create_by!(number: 50) do |s|
  s.name         = "Survivor 50"
  s.year         = 2026
  s.buy_in_cents = 1000
  s.status       = :upcoming
end
puts "Season: #{season50.name}"

# ── Weeks — Wednesdays starting Feb 25, 2026 at 8pm Eastern ──────────────────
start_date = Date.new(2026, 2, 25)  # Wednesday
18.times do |i|
  air_date  = start_date + (i * 7).days
  locked_at = Time.use_zone("Eastern Time (US & Canada)") do
    Time.zone.local(air_date.year, air_date.month, air_date.day, 20, 0, 0)
  end

  Week.find_or_create_by!(season: season50, number: i + 1) do |w|
    w.air_date        = air_date
    w.picks_locked_at = locked_at
    w.scored          = false
  end
end
puts "Weeks: #{season50.weeks.count}"
puts "Week 1 locks at: #{season50.weeks.find_by!(number: 1).picks_locked_at.in_time_zone("Eastern Time (US & Canada)")}"
