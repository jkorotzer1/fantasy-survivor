module Admin
  class SeasonsController < BaseController
    before_action :set_season, only: [:show, :edit, :update, :destroy, :activate, :complete, :scores]

    def index
      skip_authorization
      @seasons = Season.order(:number)
    end

    def show
      skip_authorization
    end

    def new
      @season = Season.new
      skip_authorization
    end

    def create
      @season = Season.new(season_params)
      skip_authorization

      if @season.save
        redirect_to admin_season_path(@season), notice: "Season created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      skip_authorization
    end

    def update
      skip_authorization

      if @season.update(season_params)
        redirect_to admin_season_path(@season), notice: "Season updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      skip_authorization
      @season.destroy
      redirect_to admin_seasons_path, notice: "Season deleted."
    end

    def activate
      skip_authorization
      @season.update!(status: :active)
      redirect_to admin_season_path(@season), notice: "Season is now active."
    end

    def complete
      skip_authorization
      @season.update!(status: :completed)
      redirect_to admin_season_path(@season), notice: "Season marked as completed."
    end

    def scores
      skip_authorization
      @weeks        = @season.weeks.ordered
      @contestants  = @season.contestants.order(:name)
      @participations = @season.participations.includes(:user,
                          weekly_picks: [:week, :contestant],
                          winner_picks: :contestant)

      # Load every scoring event for this season in one query
      all_events = ScoringEvent
                     .where(contestant: @contestants, week: @weeks)
                     .to_a

      # contestant_id => week_id => [events]
      events_lookup = all_events.group_by { |e| [e.contestant_id, e.week_id] }

      # Contestant × Week score table
      @contestant_week_scores = {}
      @contestants.each do |c|
        @contestant_week_scores[c.id] = {}
        @weeks.each do |w|
          evts = events_lookup[[c.id, w.id]] || []
          @contestant_week_scores[c.id][w.id] = evts.sum(&:point_value)
        end
      end

      @contestant_totals = @contestant_week_scores.transform_values { |wk| wk.values.sum }

      # User Picks × Week table
      @user_week_data = {}
      @participations.each do |p|
        picks_by_week = p.weekly_picks.index_by(&:week_id)
        @user_week_data[p.id] = { user: p.user, participation_id: p.id, weeks: {} }
        @weeks.each do |w|
          pick = picks_by_week[w.id]
          next unless pick
          score = @contestant_week_scores.dig(pick.contestant_id, w.id) || 0
          @user_week_data[p.id][:weeks][w.id] = { pick_id: pick.id, name: pick.contestant.name, score: score }
        end
      end
    end

    private

    def set_season
      @season = Season.find(params[:id])
    end

    def season_params
      params.require(:season).permit(:name, :number, :year, :buy_in_cents, :merge_week, :status)
    end
  end
end
