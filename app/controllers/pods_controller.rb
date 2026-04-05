class PodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pod

  def show
    @members = @pod.users
    @week_number = (Date.today - @pod.created_at.to_date).to_i / 7 + 1
    @last_activity = @pod.activities.completed.order(occurred_on: :desc).first
    @next_activity = @pod.activities.planned.where("occurred_on >= ?", Date.today)
                         .order(occurred_on: :asc).first
  end

  private

  def set_pod
    @pod = current_user.pods.find_by(id: params[:id])
    render file: "public/404.html", status: :not_found, layout: false if @pod.nil?
  end
end
