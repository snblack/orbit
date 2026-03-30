Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  get  "onboarding/:step", to: "onboarding#show",   as: :onboarding_step
  patch "onboarding/:step", to: "onboarding#update"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
