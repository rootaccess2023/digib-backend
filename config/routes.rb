# config/routes.rb
Rails.application.routes.draw do
  # Devise routes for browser access (if needed)
  devise_for :users
  
  # API routes
  namespace :api do
    post '/signup', to: 'auth#signup'
    post '/login', to: 'auth#login'
    get '/me', to: 'auth#me'
  end
  
  # Root route
  root to: 'application#welcome'
end