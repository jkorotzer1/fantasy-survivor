class ParticipationsController < ApplicationController
  before_action :set_season

  def create
    unless @season.registration_open?
      redirect_to season_path(@season), alert: "Registration is closed — the season has already started."
      return
    end

    @participation = @season.participations.build(user: current_user)

    if @participation.save
      redirect_to season_path(@season), notice: "You've joined #{@season.name}!"
    else
      redirect_to season_path(@season), alert: @participation.errors.full_messages.to_sentence
    end
  end

  def update
    @participation = current_user.participations.find_by!(season: @season)
    @participation.update!(auto_pick: params[:auto_pick])
    status = @participation.auto_pick? ? "enabled" : "disabled"
    redirect_to season_path(@season), notice: "Auto-pick #{status}."
  end

  def destroy
    @participation = current_user.participations.find_by!(season: @season)
    @participation.destroy
    redirect_to season_path(@season), notice: "You've left #{@season.name}."
  end

  private

  def set_season
    @season = Season.find(params[:season_id])
  end
end
