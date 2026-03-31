module Admin
  class ScoringEventsController < BaseController
    before_action :set_season_and_week

    def index
      skip_authorization
      @contestants = @season.contestants.order(:name)
      @events_by_contestant = @week.scoring_events
                                   .includes(:contestant)
                                   .group_by(&:contestant_id)
      @event_types = ScoringEventType.ordered
      @new_event = ScoringEvent.new
    end

    def create
      @event = @week.scoring_events.build(scoring_event_params)
      skip_authorization

      if @event.save
        redirect_to admin_season_week_scoring_events_path(@season, @week),
          notice: "Event added for #{@event.contestant.name}."
      else
        @contestants = @season.contestants.order(:name)
        @events_by_contestant = @week.scoring_events.includes(:contestant).group_by(&:contestant_id)
        @event_types = ScoringEventType.ordered
        @new_event = @event
        render :index, status: :unprocessable_entity
      end
    end

    def edit
      @event = @week.scoring_events.find(params[:id])
      skip_authorization
    end

    def update
      @event = @week.scoring_events.find(params[:id])
      skip_authorization

      if @event.update(scoring_event_params)
        redirect_to admin_season_week_scoring_events_path(@season, @week),
          notice: "Event updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def bulk_create
      skip_authorization
      event_types    = Array(params[:event_types]).reject(&:blank?)
      contestant_ids = Array(params[:contestant_ids])

      if event_types.empty? || contestant_ids.empty?
        redirect_to admin_season_week_scoring_events_path(@season, @week),
          alert: "Select at least one event type and one contestant."
        return
      end

      created = 0
      contestant_ids.each do |cid|
        event_types.each do |et|
          @week.scoring_events.create!(contestant_id: cid, event_type: et)
          created += 1
        end
      end

      redirect_to admin_season_week_scoring_events_path(@season, @week),
        notice: "#{created} event#{"s" if created != 1} added."
    end

    def destroy
      @event = @week.scoring_events.find(params[:id])
      skip_authorization
      @event.destroy
      redirect_to admin_season_week_scoring_events_path(@season, @week),
        notice: "Event removed."
    end

    private

    def set_season_and_week
      @season = Season.find(params[:season_id])
      @week   = @season.weeks.find(params[:week_id])
    end

    def scoring_event_params
      params.require(:scoring_event).permit(:contestant_id, :event_type, :notes)
    end
  end
end
