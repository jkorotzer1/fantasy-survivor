class SeasonsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :standings, :scores]
  before_action :set_season

  def index
    @seasons = Season.order(:number)
    skip_authorization
  end

  def show
    authorize @season
    @weeks = @season.weeks.ordered
    @participation = current_user&.participations&.find_by(season: @season)
    if @participation
      @picks_by_week = @participation.weekly_picks.includes(:contestant).index_by(&:week_id)
    end
    @pinned_messages = Message.top_level.pinned.includes(:user, :likes, replies: [:user, :likes], poll_options: :poll_votes)
  end

  def standings
    authorize @season
    @standings = ScoreCalculator.season_standings(@season)

    paid_count  = @season.participations.count
    gross       = paid_count * (@season.buy_in_cents / 100)
    pot         = [gross - 15, 0].max

    round5 = ->(amount) { (amount / 5.0).round * 5 }
    @payouts = {
      first:  round5.call(pot * 0.70),
      second: round5.call(pot * 0.20),
      third:  round5.call(pot * 0.10),
      paid_count: paid_count
    }
  end

  def scores
    authorize @season
    @weeks        = @season.weeks.ordered
    @contestants  = @season.contestants.order(:name)
    @participations = @season.participations.includes(:user,
                        weekly_picks: [:week, :contestant])

    all_events = ScoringEvent
                   .where(contestant: @contestants, week: @weeks)
                   .to_a

    events_lookup = all_events.group_by { |e| [e.contestant_id, e.week_id] }

    @contestant_week_scores = {}
    @contestants.each do |c|
      @contestant_week_scores[c.id] = {}
      @weeks.each do |w|
        evts = events_lookup[[c.id, w.id]] || []
        @contestant_week_scores[c.id][w.id] = evts.sum(&:point_value)
      end
    end

    @contestant_totals = @contestant_week_scores.transform_values { |wk| wk.values.sum }

    @user_week_data = {}
    @participations.each do |p|
      picks_by_week = p.weekly_picks.index_by(&:week_id)
      @user_week_data[p.id] = { user: p.user, weeks: {} }
      @weeks.each do |w|
        pick = picks_by_week[w.id]
        next unless pick
        score = @contestant_week_scores.dig(pick.contestant_id, w.id) || 0
        @user_week_data[p.id][:weeks][w.id] = { name: pick.contestant.name, score: score }
      end
    end
  end

  def my_picks
    authorize @season
    @participation = current_user.participations.find_by!(season: @season)
    @breakdown = ScoreCalculator.weekly_breakdown(@participation)
    @winner_pick = @participation.winner_picks.includes(:contestant).first
    @weeks = @season.weeks.ordered
  end

  private

  def set_season
    @season = Season.find(params[:id]) if params[:id]
    @season ||= Season.all if action_name == "index"
  end
end
