Rails.application.routes.draw do
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
  get "hello_world", to: proc { |env| [200, { 'Content-Type' => 'application/json' }, [{ message: 'Hello, World!' }.to_json]] }
  namespace :v1 do
    # Devise routes for user authentication
    devise_for :users, controllers: { registrations: 'devise_overides/users',
                                      sessions: 'devise_overides/sessions',
                                      passwords: 'devise_overides/passwords'}
   
    devise_scope :user do
    
      get "show/user", to: "users#show"
      # registrations: 'api/v1/registrations'
    end
    resources :users do
      get 'current', on: :collection # This will create '/v1/users/current'
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
    resources :inspections do
      collection do
        get 'inspection_completed'  # This route should match your controller action
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
        get 'search'
        get 'dashboard'
        delete 'bulk_delete' 
        post 'generate_report' 
      end
    end
    get 'meters/generate_meter_report', to: 'meters#generate_report', as: 'generate_meter_report'
   
    
    # Specialized meter route by division
    get 'meters/by_division/:division_id', to: 'meters#meters_by_division', as: 'meters_by_division'
    get 'meters/by_subdivision/:subdivision_id', to: 'meters#meters_by_subdivision', as: 'meters_by_subdivision'
  end
 
  # Optionally, set a root for the API if needed
  # root to: 'home#index'
end
