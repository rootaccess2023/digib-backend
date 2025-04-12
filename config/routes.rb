Rails.application.routes.draw do
  # Active Admin routes
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
    
    # User profile routes
    patch '/users/update_profile', to: 'users#update_profile'
    patch '/users/change_password', to: 'users#change_password'
    
    # Admin routes
    get '/admin/users', to: 'admin#users'
    get '/admin/users/:id', to: 'admin#show_user'
    patch '/admin/users/:id/toggle_admin', to: 'admin#toggle_admin'
    get '/admin/dashboard/stats', to: 'admin#dashboard_stats'
    
    # Barangay Admin routes
    patch '/barangay/users/:id/assign_position', to: 'barangay_admin#assign_position'
    patch '/barangay/users/:id/verify', to: 'barangay_admin#verify_user'
    get '/barangay/pending_verifications', to: 'barangay_admin#pending_verifications'
  end
  
  # Root route
  root to: redirect('/admin/login')
end