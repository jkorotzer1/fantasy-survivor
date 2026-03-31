module Admin
  class WeeksController < BaseController
    before_action :set_season
    before_action :set_week, only: [:show, :edit, :update, :destroy, :mark_scored]

    def index
      skip_authorization
      @weeks = @season.weeks.ordered
    end

    def show
      skip_authorization
      @scoring_events = @week.scoring_events.includes(:contestant).group_by(&:contestant)
    end

    def new
      @week = @season.weeks.build
      skip_authorization
    end

    def create
      @week = @season.weeks.build(week_params)
      skip_authorization

      if @week.save
        redirect_to admin_season_weeks_path(@season), notice: "Week created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      skip_authorization
    end

    def update
      skip_authorization

      if @week.update(week_params)
        redirect_to admin_season_weeks_path(@season), notice: "Week updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      skip_authorization
      @week.destroy
      redirect_to admin_season_weeks_path(@season), notice: "Week deleted."
    end

    def mark_scored
      skip_authorization
      @week.update!(scored: true)
      redirect_to admin_season_week_scoring_events_path(@season, @week),
        notice: "Week #{@week.number} marked as scored."
    end

    private

    def set_season
      @season = Season.find(params[:season_id])
    end

    def set_week
      @week = @season.weeks.find(params[:id])
    end

    def week_params
      params.require(:week).permit(:number, :air_date, :scored)
    end
  end
end
