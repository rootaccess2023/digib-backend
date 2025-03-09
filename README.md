# Rails JWT Backend

A Ruby on Rails API with JWT authentication for secure user management.

## Features

- Rails API-only application
- Devise authentication with JWT tokens
- Custom routes for signup, login, logout
- Protected user data endpoint
- CORS configuration for frontend access

## Prerequisites

- Ruby 3.0.0 or higher
- Rails 7.0.0 or higher
- PostgreSQL

## Setup

1. Clone this repository

```bash
git clone https://github.com/yourusername/rails-jwt-backend.git
cd rails-jwt-backend
```

2. Install dependencies

```bash
bundle install
```

3. Create and set up the database

```bash
rails db:create
rails db:migrate
```

4. Generate secure keys

```bash
rails secret # Copy this for DEVISE_SECRET_KEY
rails secret # Copy this for DEVISE_JWT_SECRET_KEY
```

5. Create a `.env` file in the root directory and add your keys

```
DEVISE_SECRET_KEY=your_generated_devise_secret_key_here
DEVISE_JWT_SECRET_KEY=your_generated_jwt_secret_key_here
```

6. Start the Rails server

```bash
rails server -p 3001
```

The API will be available at http://localhost:3001

## API Endpoints

| Method | Endpoint    | Description              | Parameters                                                     |
| ------ | ----------- | ------------------------ | -------------------------------------------------------------- |
| POST   | /api/signup | Register a new user      | `user[email]`, `user[password]`, `user[password_confirmation]` |
| POST   | /api/login  | Log in an existing user  | `user[email]`, `user[password]`                                |
| DELETE | /api/logout | Log out the current user | Requires Authorization header with Bearer token                |
| GET    | /api/me     | Get current user details | Requires Authorization header with Bearer token                |

## Authentication Flow

1. **Registration**: Send a POST request to `/api/signup` with user details
2. **Login**: Send a POST request to `/api/login` with credentials
3. **Token Usage**: Store the token from the response and include it in future requests in the Authorization header
4. **Logout**: Send a DELETE request to `/api/logout` with the token to invalidate it

## Development

### Running Tests

```bash
rails test
```

### Linting

```bash
rubocop
```

## Deployment

Update the CORS configuration in `config/initializers/cors.rb` to include your frontend domain.

## License

This project is open source and available under the [MIT License](LICENSE).
