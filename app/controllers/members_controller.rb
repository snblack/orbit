class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pod
  before_action :set_member

  def show; end

  private

  def set_pod
    @pod = current_user.pods.find_by(id: params[:pod_id])
    render file: "public/404.html", status: :not_found, layout: false if @pod.nil?
  end

  def set_member
    @member = @pod.users.find_by(id: params[:id])
    render file: "public/404.html", status: :not_found, layout: false if @member.nil?
  end
end
