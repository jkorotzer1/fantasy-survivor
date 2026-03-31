class MessagesController < ApplicationController
  before_action :set_message, only: [:destroy, :pin]

  def create
    @message = current_user.messages.build(message_params)
    authorize @message
    if @message.save
      redirect_to board_path, notice: @message.parent_id? ? "Reply posted." : "Message posted."
    else
      redirect_to board_path, alert: @message.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize @message
    @message.destroy
    redirect_to board_path, notice: "Message deleted."
  end

  def pin
    authorize @message, :pin?
    @message.update!(pinned: !@message.pinned?)
    redirect_to board_path, notice: @message.pinned? ? "Post pinned." : "Post unpinned."
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:body, :parent_id, :anonymous, poll_options_attributes: [:label])
  end
end
