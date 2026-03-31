module Admin
  class ParticipationsController < BaseController
    def index
      skip_authorization
      @participations = Participation.includes(:user, :season).order("seasons.number, users.name")
      @participations = @participations.where(season_id: params[:season_id]) if params[:season_id]
    end

    def create
      skip_authorization
      user   = User.find(params[:user_id])
      season = Season.find(params[:season_id])
      if Participation.exists?(user: user, season: season)
        redirect_to admin_users_path, alert: "#{user.display_name} is already in #{season.name}."
      else
        Participation.create!(user: user, season: season)
        redirect_to admin_users_path, notice: "#{user.display_name} added to #{season.name}."
      end
    end

    def destroy
      @participation = Participation.find(params[:id])
      skip_authorization
      @participation.destroy
      redirect_to admin_participations_path, notice: "#{@participation.user.display_name} removed from #{@participation.season.name}."
    end

    def update
      @participation = Participation.find(params[:id])
      skip_authorization

      if @participation.update(participation_params)
        redirect_to admin_participations_path, notice: "Participation updated."
      else
        redirect_to admin_participations_path, alert: "Update failed."
      end
    end

    private

    def participation_params
      params.require(:participation).permit(:paid_in)
    end
  end
end
