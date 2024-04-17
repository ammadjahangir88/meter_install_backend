Rails.application.routes.draw do
 
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

    
  namespace :v1 do
    devise_for :users, controllers: { registrations: 'devise_overides/users',
                                      sessions: 'devise_overides/sessions',
                                      passwords: 'devise_overides/passwords'}
    devise_scope :user do
      get "show/user", to: "users#show"
      # registrations: 'api/v1/registrations'
    end
    resources :divisions
    resources :subdivisions
    resources :discos do
      collection do
        delete "delete_regions", to: "discos#delete_regions"
        delete "delete_divisions", to: "discos#delete_divisions"
        delete "delete_subdivisions", to: "discos#delete_subdivisions"
      end
    end
    get "all_discos", to: "discos#all_discos"
    get "all_divisions", to: "divisions#index"
   
    

  end 
 
end
