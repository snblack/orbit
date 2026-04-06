class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pod

  def create
    @message = @pod.messages.build(message_params.merge(user: current_user))

    if @message.save
      message_html = render_to_string(partial: "messages/message", locals: { message: @message }, formats: [:html])
      PodChannel.broadcast_to(
        @pod,
        { sender_id: current_user.id, html: message_html }
      )
      render json: { html: message_html }, status: :ok
    else
      render json: { error: @message.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  private

  def set_pod
    @pod = current_user.pods.find_by(id: params[:pod_id])
    render json: { error: "Доступ запрещён" }, status: :forbidden if @pod.nil?
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
