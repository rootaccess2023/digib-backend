# config/routes.rb
Rails.application.routes.draw do
  #Active Admin routes
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Devise routes for browser access (if needed)
  devise_for :users, path: 'auth', controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  # API routes
  namespace :api do
    post '/signup', to: 'auth#signup'
    post '/login', to: 'auth#login'
    delete '/logout', to: 'auth#logout'
    get '/me', to: 'auth#me'
  end
  
  # Root route
  root to: redirect('/admin/login')
end