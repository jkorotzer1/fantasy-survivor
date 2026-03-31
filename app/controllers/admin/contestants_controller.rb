module Admin
  class ContestantsController < BaseController
    before_action :set_season
    before_action :set_contestant, only: [:edit, :update, :destroy]

    def index
      skip_authorization
      @contestants = @season.contestants.order(:name)
    end

    def new
      @contestant = @season.contestants.build
      skip_authorization
    end

    def create
      @contestant = @season.contestants.build(contestant_params)
      skip_authorization

      if @contestant.save
        redirect_to admin_season_contestants_path(@season), notice: "Contestant added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      skip_authorization
    end

    def update
      skip_authorization

      if @contestant.update(contestant_params)
        redirect_to admin_season_contestants_path(@season), notice: "Contestant updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      skip_authorization
      @contestant.destroy
      redirect_to admin_season_contestants_path(@season), notice: "Contestant removed."
    end

    def bulk_assign_tribe
      skip_authorization
      tribe_name    = params[:tribe].to_s.strip
      from_week_raw = params[:from_week].to_s.strip
      from_week     = from_week_raw.present? ? from_week_raw.to_i : nil
      contestant_ids = Array(params[:contestant_ids]).reject(&:blank?)

      if tribe_name.blank?
        return redirect_to admin_season_contestants_path(@season), alert: "Please enter a tribe name."
      end

      if contestant_ids.empty?
        return redirect_to admin_season_contestants_path(@season), alert: "Please select at least one contestant."
      end

      @season.contestants.where(id: contestant_ids).each do |c|
        if c.tribe.present?
          closed = {
            "name" => c.tribe,
            "from" => c.tribe_from_week,
            "to"   => from_week ? from_week - 1 : nil
          }
          c.previous_tribes = Array(c.previous_tribes).compact + [closed]
        end
        c.tribe           = tribe_name
        c.tribe_from_week = from_week
        c.save!
      end

      redirect_to admin_season_contestants_path(@season),
        notice: "#{contestant_ids.size} contestant(s) assigned to tribe '#{tribe_name}'#{from_week ? " starting week #{from_week}" : ""}."
    end

    private

    def set_season
      @season = Season.find(params[:season_id])
    end

    def set_contestant
      @contestant = @season.contestants.find(params[:id])
    end

    def contestant_params
      params.require(:contestant).permit(:name, :status, :eliminated_week, :tribe, :tribe_from_week, :previous_tribes_input)
    end
  end
end
