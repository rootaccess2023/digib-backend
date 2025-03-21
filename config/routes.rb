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
    
    # Admin routes
    get '/admin/users', to: 'admin#users'
    patch '/admin/users/:id/toggle_admin', to: 'admin#toggle_admin'
  end

  
  
  # Root route
  root to: redirect('/admin/login')
end