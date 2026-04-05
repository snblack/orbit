class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pod

  def new
    @activity = @pod.activities.build
  end

  def create
    @activity = @pod.activities.build(activity_params)
    @activity.proposed_by = current_user

    if @activity.save
      redirect_to pod_path(@pod)
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::StatementInvalid
    flash.now[:alert] = "Ошибка сервера. Попробуйте ещё раз."
    render :new, status: :internal_server_error
  end

  private

  def set_pod
    @pod = current_user.pods.find_by(id: params[:pod_id])
    render file: "public/404.html", status: :not_found, layout: false if @pod.nil?
  end

  def activity_params
    params.require(:activity).permit(:occurred_on)
  end
end
