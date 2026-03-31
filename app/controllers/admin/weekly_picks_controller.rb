module Admin
  class WeeklyPicksController < BaseController
    before_action :set_pick, only: [:edit, :update, :destroy]

    def new
      skip_authorization
      @participation = Participation.find(params[:participation_id])
      @week          = Week.find(params[:week_id])
      @pick          = WeeklyPick.new(participation: @participation, week: @week)
      @contestants   = @week.season.contestants.order(:name)
    end

    def create
      skip_authorization
      @participation = Participation.find(params[:weekly_pick][:participation_id])
      @week          = Week.find(params[:weekly_pick][:week_id])
      @pick          = WeeklyPick.new(
        participation: @participation,
        week:          @week,
        contestant_id: params[:weekly_pick][:contestant_id]
      )

      if @pick.save(validate: false)
        redirect_to scores_admin_season_path(@week.season),
          notice: "Pick added for #{@participation.user.display_name} — Week #{@week.number}."
      else
        @contestants = @week.season.contestants.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      skip_authorization
      @contestants = @pick.week.season.contestants.order(:name)
    end

    def update
      skip_authorization
      if @pick.update_columns(contestant_id: params[:weekly_pick][:contestant_id])
        redirect_to scores_admin_season_path(@pick.week.season),
          notice: "Pick updated for #{@pick.participation.user.display_name} — Week #{@pick.week.number}."
      else
        @contestants = @pick.week.season.contestants.order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      skip_authorization
      season = @pick.week.season
      user   = @pick.participation.user
      week   = @pick.week
      @pick.destroy
      redirect_to scores_admin_season_path(season),
        notice: "Deleted #{user.display_name}'s Week #{week.number} pick."
    end

    private

    def set_pick
      @pick = WeeklyPick.find(params[:id])
    end
  end
end
