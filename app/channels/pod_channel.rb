class PodChannel < ApplicationCable::Channel
  def subscribed
    pod = current_user.pods.find_by(id: params[:pod_id])
    if pod
      stream_for pod
    else
      reject
    end
  end
end
