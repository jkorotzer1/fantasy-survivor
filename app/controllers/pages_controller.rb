class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    @active_seasons = Season.active.order(:number)
    @upcoming_seasons = Season.upcoming.order(:number)
  end

  def board
    @pinned_messages = Message.top_level.pinned
      .includes(:user, replies: :user, poll_options: :poll_votes)
    @pagy, @messages = pagy(
      Message.top_level.not_pinned.chronological
        .includes(:user, replies: :user, poll_options: :poll_votes),
      items: 10
    )
  end

  def rules
    @active_season = Season.active.order(:number).first
    @event_types = ScoringEventType.order(:label)
  end
end
