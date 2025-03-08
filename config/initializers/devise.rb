# config/initializers/devise.rb
Devise.setup do |config|
  # The secret key used by Devise
  config.secret_key = ENV['DEVISE_SECRET_KEY']

  # Configure the e-mail address which will be shown in emails
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  # Load and configure the ORM. Supports :active_record (default)
  require 'devise/orm/active_record'

  # Configure which authentication keys should be case-insensitive
  config.case_insensitive_keys = [:email]

  # Configure which authentication keys should have whitespace stripped
  config.strip_whitespace_keys = [:email]

  # Skip session storage for API-only applications
  config.skip_session_storage = [:http_auth]

  # For API mode
  config.navigational_formats = []

  # ==> Configuration for :database_authenticatable
  config.stretches = Rails.env.test? ? 1 : 12

  # ==> Configuration for :validatable
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> Configuration for :recoverable
  config.reset_password_within = 6.hours

  # The default HTTP method used to sign out a resource
  config.sign_out_via = :delete

  # Simple JWT Configuration
  config.jwt do |jwt|
    jwt.secret = ENV['DEVISE_JWT_SECRET_KEY']
    jwt.dispatch_requests = [
      ['POST', %r{^/login$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/logout$}]
    ]
    jwt.expiration_time = 1.day.to_i
  end
end