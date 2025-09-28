Rails.application.routes.draw do
  get "doctors/index"
  get "doctors/show"
  get "patients/index"
  get "patients/show"

  resources :patients do
    member do
      get 'bmi_calculate'
      post 'calculate_bmr'
      get 'bmr_history'
    end
  end

  resources :doctors
  root 'home#index'
  #get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
 # get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
