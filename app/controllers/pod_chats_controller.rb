class PodChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pod

  def show
    @messages = @pod.messages
                    .includes(:user)
                    .order(created_at: :desc)
                    .limit(50)
                    .reverse

    if params[:before_id].present?
      pivot = @pod.messages.find_by(id: params[:before_id])
      if pivot
        @messages = @pod.messages
                        .includes(:user)
                        .where("created_at < ?", pivot.created_at)
                        .order(created_at: :desc)
                        .limit(50)
                        .reverse
      end
    end
  end

  private

  def set_pod
    @pod = current_user.pods.find_by(id: params[:pod_id])
    render file: "public/404.html", status: :not_found, layout: false if @pod.nil?
  end
end
