module Admin
  class DashboardController < BaseController
    def index
      skip_authorization
      @seasons = Season.order(:number)
      @recent_weeks = Week.includes(:season).order(air_date: :desc).limit(5)
      @pending_payments = Participation.where(paid_in: false).includes(:user, :season).limit(10)
    end
  end
end
