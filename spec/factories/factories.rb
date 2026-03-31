FactoryBot.define do
  factory :user do
    name  { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123!" }
    role { :player }
  end

  factory :season do
    sequence(:number) { |n| n }
    sequence(:name)   { |n| "Survivor #{n}" }
    year  { 2026 }
    buy_in_cents { 1000 }
    status { :upcoming }
  end

  factory :contestant do
    association :season
    sequence(:name) { |n| "Contestant #{n}" }
    status { :active }
  end

  factory :participation do
    association :user
    association :season
    paid_in { false }
  end

  factory :week do
    association :season
    sequence(:number) { |n| n }
    air_date { Date.today + 7.days }
    picks_locked_at { 2.days.from_now }
    scored { false }
  end

  factory :weekly_pick do
    association :participation
    association :week
    association :contestant
  end

  factory :winner_pick do
    association :participation
    association :contestant
    week_locked { 1 }
  end

  factory :scoring_event do
    association :contestant
    association :week
    event_type { "survived_week" }
  end
end
