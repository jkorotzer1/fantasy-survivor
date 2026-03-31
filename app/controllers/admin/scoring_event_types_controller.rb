module Admin
  class ScoringEventTypesController < BaseController
    before_action :set_event_type, only: [:edit, :update, :destroy]

    def index
      skip_authorization
      @event_types = ScoringEventType.ordered
    end

    def new
      skip_authorization
      @event_type = ScoringEventType.new
    end

    def create
      skip_authorization
      @event_type = ScoringEventType.new(event_type_params)

      if @event_type.save
        redirect_to admin_scoring_event_types_path, notice: "\"#{@event_type.label}\" added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      skip_authorization
    end

    def update
      skip_authorization
      if @event_type.update(event_type_params)
        redirect_to admin_scoring_event_types_path, notice: "\"#{@event_type.label}\" updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      skip_authorization
      @event_type.destroy
      redirect_to admin_scoring_event_types_path, notice: "Event type deleted."
    end

    private

    def set_event_type
      @event_type = ScoringEventType.find(params[:id])
    end

    def event_type_params
      params.require(:scoring_event_type).permit(:key, :label, :points, :is_elimination, :is_winner)
    end
  end
end
