require "net/http"
require "json"

class OnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :set_step

  STEPS = %w[life_phase values rhythm interests location media profile].freeze

  def show
    @ip_location = detect_ip_location if @step == "location"
  end

  def update
    current_user.assign_attributes(step_params)
    validation_context = :"onboarding_#{@step}"

    if current_user.valid?(validation_context) && current_user.save
      next_step = STEPS[STEPS.index(@step) + 1]
      if next_step.nil?
        current_user.update!(onboarding_completed: true)
        redirect_to root_path, notice: "Добро пожаловать в Orbit!"
      else
        redirect_to onboarding_step_path(step: next_step)
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_step
    @step = params[:step]
    redirect_to onboarding_step_path(step: STEPS.first) unless STEPS.include?(@step)
    @step_index = STEPS.index(@step)
    @total_steps = STEPS.size
  end

  def detect_ip_location
    ip = request.remote_ip
    ip = nil if ip == "127.0.0.1" || ip == "::1" # localhost — не отправляем в API

    return nil if ip.nil?

    uri = URI("http://ip-api.com/json/#{ip}?fields=city,lat,lon,status&lang=ru")
    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    return nil unless data["status"] == "success"

    { city: data["city"], lat: data["lat"], lon: data["lon"] }
  rescue StandardError
    nil
  end

  def step_params
    case @step
    when "life_phase"
      params.require(:user).permit(:life_phase)
    when "values"
      params.require(:user).permit(:social_style, :friendship_goal, :openness_level)
    when "rhythm"
      params.require(:user).permit(:social_frequency, schedule_preference: {})
    when "interests"
      params.require(:user).permit(interests: [])
    when "location"
      params.require(:user).permit(:location_district, :latitude, :longitude)
    when "media"
      {} # ActiveStorage — отложено до фазы профиля
    when "profile"
      params.require(:user).permit(:display_name, :bio)
    else
      {}
    end
  end
end
