class LikesController < ApplicationController
  def create
    @message = Message.find(params[:message_id])
    @like = current_user.likes.build(message: @message)
    authorize @like
    @like.save
    redirect_to board_path
  end

  def destroy
    @like = current_user.likes.find_by!(message_id: params[:message_id])
    authorize @like
    @like.destroy
    redirect_to board_path
  end
end
