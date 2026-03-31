require "rails_helper"

RSpec.describe ScoreCalculator do
  let(:season)        { create(:season) }
  let(:user)          { create(:user) }
  let(:participation) { create(:participation, user: user, season: season) }
  let(:contestant)    { create(:contestant, season: season) }
  let(:week)          { create(:week, season: season, picks_locked_at: 1.day.ago, scored: true) }

  describe ".weekly_total" do
    it "sums points for picked contestants" do
      create(:weekly_pick, participation: participation, week: week, contestant: contestant)
      create(:scoring_event, contestant: contestant, week: week, event_type: "survived_week") # +1
      create(:scoring_event, contestant: contestant, week: week, event_type: "individual_immunity") # +3

      expect(ScoreCalculator.weekly_total(participation)).to eq(4)
    end

    it "returns 0 with no picks" do
      expect(ScoreCalculator.weekly_total(participation)).to eq(0)
    end

    it "does not count events from weeks the player did not pick" do
      other_contestant = create(:contestant, season: season)
      create(:weekly_pick, participation: participation, week: week, contestant: contestant)
      create(:scoring_event, contestant: other_contestant, week: week, event_type: "survived_week")

      expect(ScoreCalculator.weekly_total(participation)).to eq(0)
    end
  end

  describe ".winner_pick_score" do
    it "returns winner pick points when correct" do
      contestant.update!(status: :winner)
      create(:winner_pick, participation: participation, contestant: contestant, week_locked: 1)

      expect(ScoreCalculator.winner_pick_score(participation)).to eq(40)
    end

    it "returns 0 when pick is wrong" do
      create(:winner_pick, participation: participation, contestant: contestant, week_locked: 1)

      expect(ScoreCalculator.winner_pick_score(participation)).to eq(0)
    end

    it "returns 0 when no winner pick" do
      expect(ScoreCalculator.winner_pick_score(participation)).to eq(0)
    end
  end

  describe ".total_score" do
    it "combines weekly and winner pick scores" do
      contestant.update!(status: :winner)
      create(:weekly_pick, participation: participation, week: week, contestant: contestant)
      create(:scoring_event, contestant: contestant, week: week, event_type: "survived_week")
      create(:winner_pick, participation: participation, contestant: contestant, week_locked: 2)

      # 1 (survived_week) + 36 (winner pick week 2) = 37
      expect(ScoreCalculator.total_score(participation)).to eq(37)
    end
  end

  describe ".season_standings" do
    it "returns standings sorted by score descending" do
      user2 = create(:user)
      participation2 = create(:participation, user: user2, season: season)

      create(:weekly_pick, participation: participation, week: week, contestant: contestant)
      create(:scoring_event, contestant: contestant, week: week, event_type: "individual_immunity") # +3

      standings = ScoreCalculator.season_standings(season)
      expect(standings.first[:user]).to eq(user)
      expect(standings.first[:total]).to eq(3)
      expect(standings.last[:user]).to eq(user2)
    end
  end
end
