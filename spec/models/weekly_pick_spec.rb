require "rails_helper"

RSpec.describe WeeklyPick, type: :model do
  let(:season)        { create(:season) }
  let(:user)          { create(:user) }
  let(:participation) { create(:participation, user: user, season: season) }
  let(:contestant)    { create(:contestant, season: season) }
  let(:open_week)     { create(:week, season: season, picks_locked_at: 2.days.from_now) }
  let(:locked_week)   { create(:week, season: season, picks_locked_at: 1.hour.ago) }

  describe "validations" do
    context "when the week is open" do
      it "allows a valid pick" do
        pick = WeeklyPick.new(participation: participation, week: open_week, contestant: contestant)
        expect(pick).to be_valid
      end
    end

    context "when the week is locked" do
      it "rejects the pick" do
        pick = WeeklyPick.new(participation: participation, week: locked_week, contestant: contestant)
        expect(pick).not_to be_valid
        expect(pick.errors[:base]).to include("Picks are locked for this week")
      end
    end

    context "pick limit enforcement" do
      it "allows picking a contestant a second time" do
        other_week = create(:week, season: season, picks_locked_at: 3.days.from_now)
        create(:weekly_pick, participation: participation, week: open_week, contestant: contestant)

        second_pick = WeeklyPick.new(participation: participation, week: other_week, contestant: contestant)
        expect(second_pick).to be_valid
      end

      it "blocks a third pick of the same contestant" do
        week2 = create(:week, season: season, picks_locked_at: 3.days.from_now)
        week3 = create(:week, season: season, picks_locked_at: 4.days.from_now)
        create(:weekly_pick, participation: participation, week: open_week, contestant: contestant)
        create(:weekly_pick, participation: participation, week: week2, contestant: contestant)

        third_pick = WeeklyPick.new(participation: participation, week: week3, contestant: contestant)
        expect(third_pick).not_to be_valid
        expect(third_pick.errors[:contestant]).to be_present
      end
    end

    context "contestant validation" do
      it "rejects a contestant from a different season" do
        other_season    = create(:season)
        other_contestant = create(:contestant, season: other_season)
        pick = WeeklyPick.new(participation: participation, week: open_week, contestant: other_contestant)
        expect(pick).not_to be_valid
        expect(pick.errors[:contestant]).to include("does not belong to this season")
      end

      it "rejects an eliminated contestant" do
        eliminated = create(:contestant, season: season, status: :eliminated)
        pick = WeeklyPick.new(participation: participation, week: open_week, contestant: eliminated)
        expect(pick).not_to be_valid
        expect(pick.errors[:contestant]).to include("has been eliminated and cannot be picked")
      end
    end

    context "uniqueness" do
      it "prevents two picks for the same participant in the same week" do
        create(:weekly_pick, participation: participation, week: open_week, contestant: contestant)
        other_contestant = create(:contestant, season: season)
        dup = WeeklyPick.new(participation: participation, week: open_week, contestant: other_contestant)
        expect(dup).not_to be_valid
        expect(dup.errors[:participation_id]).to be_present
      end
    end
  end
end
