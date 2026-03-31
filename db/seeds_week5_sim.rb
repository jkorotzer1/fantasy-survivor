# Week 5 simulation seed — run with:
#   rails db:seed:replant (wipes + runs seeds.rb first)
#   OR: rails runner db/seeds_week5_sim.rb
#
# Simulates a season mid-game: weeks 1-4 scored, week 5 is upcoming (picks open),
# 3 contestants eliminated, real picks and scores for all players.

puts "=== Week 5 Simulation Seed ==="

# ── Scoring event types (mirror production) ──────────────────────────────────
unless ScoringEventType.exists?
  types = [
    { key: "survived_week",        label: "🏝️ Survived the Week",              points:  1 },
    { key: "right_vote_premerge",  label: "🗳️ Right Vote (Pre-Merge)",          points:  1 },
    { key: "right_vote_postmerge", label: "🗳️ Right Vote (Post-Merge)",         points:  2 },
    { key: "reward_1st",           label: "🏆 Won Reward (1st)",                points:  2 },
    { key: "reward_2nd",           label: "🎁 Won Reward (2nd)",                points:  1 },
    { key: "team_immunity_1st",    label: "🛡️ Team Immunity (1st)",             points:  2 },
    { key: "team_immunity_2nd",    label: "🛡️ Team Immunity (2nd)",             points:  1 },
    { key: "found_idol",           label: "🗿 Found Idol/Advantage",            points:  3 },
    { key: "journey",              label: "⛵ Went on Journey",                 points:  1 },
    { key: "shot_in_dark",         label: "🎲 Shot in the Dark",                points:  5 },
    { key: "idol_play",            label: "⚡ Played Idol Successfully",        points:  5 },
    { key: "advantage_play",       label: "🃏 Played Advantage Successfully",   points:  3 },
    { key: "voted_out",            label: "🪦 Voted Out",                       points: -3, is_elimination: true },
    { key: "voted_out_with_idol",  label: "🤦 Voted Out with Idol/Advantage",   points: -2, is_elimination: true },
    { key: "lost_vote",            label: "🚫 Lost Their Vote",                 points: -1 },
    { key: "quit",                 label: "🚪 Quit",                            points: -5, is_elimination: true },
    { key: "gained_advantage",     label: "🎴 Gained Advantage",                points:  2 },
    { key: "individual_immunity",  label: "🏅 Won Individual Immunity",         points:  3 },
    { key: "med_evac",             label: "🚑 Medical Evacuation",              points: -3, is_elimination: true },
    { key: "taken_on_reward",      label: "🎟️ Taken on Reward",                 points:  1 },
    { key: "quote_of_week",        label: "💬 Quote of the Week",               points:  2 },
    { key: "survivor_record",      label: "📜 Set Survivor Record",             points:  5 },
    { key: "potw_top3",            label: "⭐ Player of the Week Top 3",        points:  2 },
    { key: "ftc_won_fire",         label: "🔥 FTC: Won Fire",                   points:  3 },
    { key: "ftc_lost_fire",        label: "💨 FTC: Lost Fire",                  points: -3 },
    { key: "ftc_brought",          label: "🤝 FTC: Brought to Final",           points:  1 },
    { key: "ftc_winner",           label: "👑 FTC: Winner",                     points:  2, is_winner: true },
    { key: "ftc_survived_final5",  label: "🖐️ FTC: Survived Final 5",           points:  1 },
  ]
  types.each { |t| ScoringEventType.create!(t) }
  puts "Created #{ScoringEventType.count} scoring event types"
end

# ── Admin + players ───────────────────────────────────────────────────────────
admin = User.find_or_create_by!(email: "admin@test.com") do |u|
  u.name = "Admin"; u.password = "password123!"; u.role = :admin
end
admin.update!(role: :admin)
puts "Admin: #{admin.email}"

players = [
  { name: "Alice",   email: "alice@test.com"   },
  { name: "Bob",     email: "bob@test.com"      },
  { name: "Carol",   email: "carol@test.com"    },
  { name: "Dave",    email: "dave@test.com"     },
  { name: "Eve",     email: "eve@test.com"      },
  { name: "Frank",   email: "frank@test.com"    },
]
player_users = players.map do |p|
  User.find_or_create_by!(email: p[:email]) do |u|
    u.name = p[:name]; u.password = "password123!"
  end
end
puts "Players: #{player_users.map(&:name).join(", ")}"

# ── Season ────────────────────────────────────────────────────────────────────
season = Season.find_or_create_by!(number: 49) do |s|
  s.name = "Survivor 49"; s.year = 2025; s.buy_in_cents = 1000; s.status = :active
end
season.update!(status: :active)
puts "Season: #{season.name}"

# ── Contestants (18, 3 eliminated) ───────────────────────────────────────────
cast = [
  { name: "Austin",   status: :active },
  { name: "Dee",      status: :active },
  { name: "Jake",     status: :active },
  { name: "Katurah",  status: :active },
  { name: "Sam",      status: :active },
  { name: "Tevin",    status: :active },
  { name: "Tiyana",   status: :active },
  { name: "TK",       status: :active },
  { name: "Drew",     status: :active },
  { name: "Julie",    status: :active },
  { name: "Sifu",     status: :active },
  { name: "Sophie",   status: :active },
  { name: "Hunter",   status: :active },
  { name: "Shauhin",  status: :active },
  { name: "Kellie",   status: :eliminated, eliminated_week: 3 },
  { name: "Brando",   status: :eliminated, eliminated_week: 2 },
  { name: "Sabiyah",  status: :eliminated, eliminated_week: 1 },
  { name: "Sean",     status: :active },
]
contestants = cast.map do |c|
  Contestant.find_or_create_by!(season: season, name: c[:name]) do |con|
    con.status = c[:status]; con.eliminated_week = c[:eliminated_week]
  end
end
puts "Contestants: #{contestants.count} (#{contestants.count(&:eliminated?)} eliminated)"

# Helper to find a contestant by name
def find_c(season, name)
  season.contestants.find_by!(name: name)
end

# ── Weeks (18 total, weeks 1-4 scored, week 5 upcoming) ──────────────────────
today = Date.today
# Weeks 1-4 are in the past, week 5 is next week
week_dates = (1..18).map { |i| today - ((5 - i) * 7) }

weeks = (1..18).map do |i|
  air_date  = week_dates[i - 1]
  locked_at = Time.use_zone("Eastern Time (US & Canada)") do
    Time.zone.local(air_date.year, air_date.month, air_date.day, 20, 0, 0)
  end
  scored = i <= 4
  Week.find_or_create_by!(season: season, number: i) do |w|
    w.air_date = air_date; w.picks_locked_at = locked_at; w.scored = scored
  end.tap { |w| w.update!(scored: scored, air_date: air_date, picks_locked_at: locked_at) }
end
puts "Weeks: #{weeks.count} (#{weeks.count(&:scored?)} scored)"

# ── Participations ────────────────────────────────────────────────────────────
participations = player_users.map do |u|
  Participation.find_or_create_by!(user: u, season: season) { |p| p.paid_in = true }
end

# ── Scoring events for weeks 1-4 ─────────────────────────────────────────────
# Clear old events and picks for clean re-seed
ScoringEvent.where(week: weeks[0..3]).destroy_all
WeeklyPick.where(week: weeks[0..3]).destroy_all

def add_event(contestant, week, event_key, notes = nil)
  ScoringEvent.create!(contestant: contestant, week: week, event_type: event_key, notes: notes)
end

# Week 1 — Sabiyah voted out
w1 = weeks[0]
sabiyah = find_c(season, "Sabiyah")
[["Austin","survived_week"],["Dee","survived_week"],["Jake","survived_week"],
 ["Katurah","survived_week"],["Sam","survived_week"],["Tevin","survived_week"],
 ["Tiyana","survived_week"],["TK","survived_week"],["Drew","survived_week"],
 ["Julie","survived_week"],["Sifu","survived_week"],["Sophie","survived_week"],
 ["Hunter","survived_week"],["Shauhin","survived_week"],["Kellie","survived_week"],
 ["Brando","survived_week"],["Sean","survived_week"]].each do |name, key|
  add_event(find_c(season, name), w1, key)
end
add_event(find_c(season, "Austin"),  w1, "team_immunity_1st")
add_event(find_c(season, "Dee"),     w1, "reward_1st")
add_event(find_c(season, "Jake"),    w1, "found_idol")
add_event(find_c(season, "Tiyana"),  w1, "right_vote_premerge")
add_event(find_c(season, "Drew"),    w1, "right_vote_premerge")
add_event(find_c(season, "Hunter"),  w1, "right_vote_premerge")
add_event(find_c(season, "Hunter"),  w1, "quote_of_week")
add_event(sabiyah,                   w1, "voted_out")
sabiyah.update!(status: :eliminated, eliminated_week: 1)

# Week 2 — Brando voted out
w2 = weeks[1]
brando = find_c(season, "Brando")
[["Austin","survived_week"],["Dee","survived_week"],["Jake","survived_week"],
 ["Katurah","survived_week"],["Sam","survived_week"],["Tevin","survived_week"],
 ["Tiyana","survived_week"],["TK","survived_week"],["Drew","survived_week"],
 ["Julie","survived_week"],["Sifu","survived_week"],["Sophie","survived_week"],
 ["Hunter","survived_week"],["Shauhin","survived_week"],["Kellie","survived_week"],
 ["Sean","survived_week"]].each do |name, key|
  add_event(find_c(season, name), w2, key)
end
add_event(find_c(season, "TK"),      w2, "team_immunity_1st")
add_event(find_c(season, "Katurah"), w2, "team_immunity_2nd")
add_event(find_c(season, "Sam"),     w2, "reward_1st")
add_event(find_c(season, "Sophie"),  w2, "reward_2nd")
add_event(find_c(season, "Tevin"),   w2, "found_idol")
add_event(find_c(season, "Julie"),   w2, "journey")
add_event(find_c(season, "Dee"),     w2, "right_vote_premerge")
add_event(find_c(season, "Austin"),  w2, "right_vote_premerge")
add_event(find_c(season, "Shauhin"), w2, "right_vote_premerge")
add_event(brando,                    w2, "voted_out")
brando.update!(status: :eliminated, eliminated_week: 2)

# Week 3 — Kellie voted out
w3 = weeks[2]
kellie = find_c(season, "Kellie")
[["Austin","survived_week"],["Dee","survived_week"],["Jake","survived_week"],
 ["Katurah","survived_week"],["Sam","survived_week"],["Tevin","survived_week"],
 ["Tiyana","survived_week"],["TK","survived_week"],["Drew","survived_week"],
 ["Julie","survived_week"],["Sifu","survived_week"],["Sophie","survived_week"],
 ["Hunter","survived_week"],["Shauhin","survived_week"],["Sean","survived_week"]].each do |name, key|
  add_event(find_c(season, name), w3, key)
end
add_event(find_c(season, "Sifu"),    w3, "individual_immunity")
add_event(find_c(season, "Drew"),    w3, "reward_1st")
add_event(find_c(season, "Sean"),    w3, "reward_2nd")
add_event(find_c(season, "Jake"),    w3, "idol_play")
add_event(find_c(season, "Jake"),    w3, "right_vote_premerge")
add_event(find_c(season, "TK"),      w3, "right_vote_premerge")
add_event(find_c(season, "Tiyana"),  w3, "right_vote_premerge")
add_event(find_c(season, "Katurah"), w3, "right_vote_premerge")
add_event(find_c(season, "Dee"),     w3, "potw_top3")
add_event(kellie,                    w3, "voted_out")
kellie.update!(status: :eliminated, eliminated_week: 3)

# Week 4 — Close vote, idol flush
w4 = weeks[3]
[["Austin","survived_week"],["Dee","survived_week"],["Jake","survived_week"],
 ["Katurah","survived_week"],["Sam","survived_week"],["Tevin","survived_week"],
 ["Tiyana","survived_week"],["TK","survived_week"],["Drew","survived_week"],
 ["Julie","survived_week"],["Sifu","survived_week"],["Sophie","survived_week"],
 ["Hunter","survived_week"],["Shauhin","survived_week"],["Sean","survived_week"]].each do |name, key|
  add_event(find_c(season, name), w4, key)
end
add_event(find_c(season, "Austin"),  w4, "individual_immunity")
add_event(find_c(season, "Sam"),     w4, "reward_1st")
add_event(find_c(season, "Tiyana"),  w4, "reward_2nd")
add_event(find_c(season, "Tevin"),   w4, "gained_advantage")
add_event(find_c(season, "Hunter"),  w4, "shot_in_dark")
add_event(find_c(season, "Shauhin"), w4, "right_vote_premerge")
add_event(find_c(season, "Dee"),     w4, "right_vote_premerge")
add_event(find_c(season, "Julie"),   w4, "right_vote_premerge")
add_event(find_c(season, "Sifu"),    w4, "quote_of_week")
add_event(find_c(season, "Sean"),    w4, "potw_top3")

puts "Scoring events: #{ScoringEvent.count}"

# ── Weekly picks (weeks 1-4, simulated for each player) ──────────────────────
# Each player can pick each contestant max twice
# pick[player_index][week_index] = contestant name
pick_matrix = [
  # Alice:  w1         w2        w3        w4
  ["Austin",  "Jake",   "Sifu",   "Austin"],
  # Bob:
  ["Dee",     "TK",     "Drew",   "Sam"   ],
  # Carol:
  ["Hunter",  "Tevin",  "Jake",   "Dee"   ],
  # Dave:
  ["Jake",    "Sam",    "Austin", "Tiyana"],
  # Eve:
  ["Tiyana",  "Dee",    "Katurah","Austin"],
  # Frank:
  ["Drew",    "Shauhin","Dee",    "Sifu"  ],
]

pick_matrix.each_with_index do |picks, pi|
  participation = participations[pi]
  picks.each_with_index do |cname, wi|
    week = weeks[wi]
    contestant = find_c(season, cname)
    unless WeeklyPick.exists?(participation: participation, week: week)
      wp = WeeklyPick.new(participation: participation, week: week, contestant: contestant)
      wp.save!(validate: false)
    end
  end
end
puts "Weekly picks: #{WeeklyPick.count}"

# ── Winner picks ──────────────────────────────────────────────────────────────
WinnerPick.destroy_all
[
  [participations[0], "Austin",  1],  # Alice — picked week 1
  [participations[1], "Dee",     2],  # Bob   — picked week 2
  [participations[2], "Jake",    1],  # Carol — picked week 1
  [participations[3], "Sam",     3],  # Dave  — picked week 3
                                      # Eve and Frank haven't picked yet
].each do |part, cname, wk|
  WinnerPick.create!(participation: part, contestant: find_c(season, cname), week_locked: wk)
end
puts "Winner picks: #{WinnerPick.count}"

puts ""
puts "=== Done! ==="
puts "  Season:     #{season.name} (#{season.status})"
puts "  Weeks 1-4:  scored"
puts "  Week 5:     upcoming (picks open)"
puts "  Players:    #{player_users.map { |u| "#{u.name} (#{u.email})" }.join(", ")}"
puts "  Password:   password123!"
puts "  Admin:      admin@test.com / password123!"
puts ""
puts "Standings preview:"
season.participations.each do |p|
  total = ScoreCalculator.total_score(p)
  puts "  #{p.user.name}: #{total} pts"
end
