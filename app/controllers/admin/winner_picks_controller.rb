module Admin
  class WinnerPicksController < BaseController
    before_action :set_winner_pick, only: [:edit, :update, :destroy]

    def new
      skip_authorization
      @participation = Participation.find(params[:participation_id])
      @season        = @participation.season
      @winner_pick   = @participation.winner_picks.build
      @contestants   = @season.contestants.order(:name)
    end

    def create
      skip_authorization
      @participation = Participation.find(params[:winner_pick][:participation_id])
      @season        = @participation.season
      current_week   = @season.current_winner_pick_week&.number || 1

      @winner_pick = @participation.winner_picks.build(
        contestant_id: params[:winner_pick][:contestant_id],
        week_locked:   params[:winner_pick][:week_locked].presence || current_week
      )

      if @winner_pick.save
        redirect_to scores_admin_season_path(@season),
          notice: "Winner pick added for #{@participation.user.display_name}."
      else
        @contestants = @season.contestants.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      skip_authorization
      @season      = @winner_pick.participation.season
      @contestants = @season.contestants.order(:name)
    end

    def update
      skip_authorization
      if @winner_pick.update(winner_pick_params)
        redirect_to scores_admin_season_path(@winner_pick.participation.season),
          notice: "Winner pick updated."
      else
        @season      = @winner_pick.participation.season
        @contestants = @season.contestants.order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      skip_authorization
      season = @winner_pick.participation.season
      @winner_pick.destroy
      redirect_to scores_admin_season_path(season), notice: "Winner pick deleted."
    end

    private

    def set_winner_pick
      @winner_pick = WinnerPick.find(params[:id])
    end

    def winner_pick_params
      params.require(:winner_pick).permit(:contestant_id, :week_locked)
    end
  end
end
