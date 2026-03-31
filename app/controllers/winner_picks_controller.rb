class WinnerPicksController < ApplicationController
  before_action :set_season
  before_action :set_participation
  before_action :check_no_existing_winner_pick

  def new
    @pick = @participation.winner_picks.build
    @contestants = @season.contestants.active
    authorize @pick
  end

  def create
    current_week_number = @season.current_winner_pick_week&.number || 1

    @pick = @participation.winner_picks.build(
      winner_pick_params.merge(week_locked: current_week_number)
    )
    authorize @pick

    if @pick.save
      redirect_to my_picks_season_path(@season),
        notice: "Winner pick saved! You picked #{@pick.contestant.name}."
    else
      @contestants = @season.contestants.active
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_season
    @season = Season.find(params[:season_id])
  end

  def set_participation
    @participation = current_user.participations.find_by!(season: @season)
  end

  def check_no_existing_winner_pick
    if @participation.has_winner_pick?
      redirect_to my_picks_season_path(@season),
        alert: "You've already made your winner pick and it cannot be changed."
    end
  end

  def winner_pick_params
    params.require(:winner_pick).permit(:contestant_id)
  end
end
