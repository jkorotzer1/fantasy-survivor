class PollVotesController < ApplicationController
  def create
    option = PollOption.find(params[:poll_vote][:poll_option_id])
    @vote = PollVote.new(user: current_user, poll_option: option)
    authorize @vote
    if @vote.save
      redirect_to board_path, notice: "Vote recorded!"
    else
      redirect_to board_path, alert: @vote.errors.full_messages.to_sentence
    end
  end
end
