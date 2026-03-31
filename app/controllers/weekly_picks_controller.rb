class WeeklyPicksController < ApplicationController
  before_action :set_season_and_week
  before_action :set_participation
  before_action :check_picks_open, except: []

  def new
    @pick = @participation.weekly_picks.find_by(week: @week) || WeeklyPick.new
    set_contestant_lists
    authorize @pick
  end

  def create
    @pick = @participation.weekly_picks.build(weekly_pick_params.merge(week: @week))
    authorize @pick

    if @pick.save
      redirect_to season_week_path(@season, @week), notice: "Pick saved!"
    else
      set_contestant_lists
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @pick = @participation.weekly_picks.find_by!(week: @week)
    authorize @pick

    if @pick.update(weekly_pick_params)
      redirect_to season_week_path(@season, @week), notice: "Pick updated!"
    else
      set_contestant_lists
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @pick = @participation.weekly_picks.find_by!(week: @week)
    authorize @pick
    @pick.destroy
    redirect_to season_week_path(@season, @week), notice: "Pick removed."
  end

  private

  def set_season_and_week
    @season = Season.find(params[:season_id])
    @week   = @season.weeks.find(params[:week_id])
  end

  def set_participation
    @participation = current_user.participations.find_by!(season: @season)
  end

  def check_picks_open
    if @week.locked?
      redirect_to season_week_path(@season, @week),
        alert: "Picks are locked for Week #{@week.number}."
    end
  end

  def weekly_pick_params
    params.require(:weekly_pick).permit(:contestant_id)
  end

  def set_contestant_lists
    used_twice = if @pick&.persisted?
      @participation.weekly_picks
                    .where.not(id: @pick.id)
                    .group(:contestant_id)
                    .having("COUNT(*) >= #{Participation::MAX_PICKS_PER_CONTESTANT}")
                    .pluck(:contestant_id)
    else
      @participation.contestants_used_twice
    end
    @available_contestants = @season.contestants.active.order(:name)
    @maxed_contestant_ids  = used_twice.to_set
  end
end
