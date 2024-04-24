Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :v1 do
    # Devise routes for user authentication
    devise_for :users, controllers: {
      registrations: 'devise_overrides/users',
      sessions: 'devise_overrides/sessions',
      passwords: 'devise_overrides/passwords'
    }
    devise_scope :user do
      get "show/user", to: "users#show"
    end

    # Resources and nested routes
    resources :divisions
    resources :subdivisions
    resources :regions
    resources :discos do
      collection do
        delete "delete_discos"
        delete "delete_regions"
        delete "delete_divisions"
        delete "delete_subdivisions"
      end
    end

    # Additional routes for discos
    get "all_discos", to: "discos#all_discos"
    get "divisions/:id/meters", to: "divisions#meters", as: 'division_meters'

    # Meters routes ensuring export and import are correctly handled
    resources :meters do
      collection do
        post 'import'
        post 'export'
        get 'dashboard'
      end
    end

    # Specialized meter route by division
    get 'meters/by_division/:division_id', to: 'meters#meters_by_division', as: 'meters_by_division'
  end

  # Optionally, set a root for the API if needed
  # root to: 'home#index'
end
