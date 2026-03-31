class WeeksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :set_season_and_week

  def show
    skip_authorization
    @participation = current_user&.participations&.find_by(season: @season)
    @existing_pick = @participation&.weekly_picks&.find_by(week: @week)
    @scoring_events = @week.scoring_events.includes(:contestant).group_by(&:contestant)
    @contestants = @season.contestants.order(:name)
  end

  private

  def set_season_and_week
    @season = Season.find(params[:season_id])
    @week   = @season.weeks.find(params[:id])
  end
end
