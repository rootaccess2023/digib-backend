# Rails JWT API with Admin Role Management

A Ruby on Rails API with JWT authentication and admin role management.

## Features

- Rails API application with JWT authentication
- Role-based access control with admin privileges
- Custom endpoints for user management
- Admin functionality separate from ActiveAdmin
- JWT token-based authentication and authorization

## System Requirements

- Ruby 3.3.1
- Rails 7.1.5
- PostgreSQL

## Setup

1. Clone this repository:

```bash
git clone https://github.com/your-username/your-backend-repo.git
cd your-backend-repo
```

2. Install dependencies:

```bash
bundle install
```

3. Create and set up the database:

```bash
rails db:create
rails db:migrate
```

4. Run the admin creation task:

```bash
rails users:create_admin ADMIN_EMAIL=admin@example.com ADMIN_PASSWORD=yourpassword
```

5. Start the server:

```bash
rails server -p 3000
```

## API Authentication

Authentication is handled using JWT tokens. Include the token in the Authorization header:

```
Authorization: Bearer your_jwt_token
```

## API Endpoints

### Authentication

- `POST /api/signup` - Register a new user
  - Parameters: `{ "user": { "email": "user@example.com", "password": "password", "password_confirmation": "password" } }`
- `POST /api/login` - Login a user
  - Parameters: `{ "user": { "email": "user@example.com", "password": "password" } }`
- `DELETE /api/logout` - Logout a user
  - Requires authentication token
- `GET /api/me` - Get current user info
  - Requires authentication token

### Admin-Only Endpoints

- `GET /api/admin/users` - Get all users
  - Requires authentication token with admin privileges
- `PATCH /api/admin/users/:id/toggle_admin` - Toggle admin status for a user
  - Requires authentication token with admin privileges

## User Roles

The application supports two user roles:

1. **Regular Users**
   - Can access their own data
   - Cannot access admin endpoints
2. **Admin Users**
   - Can access all regular user functionality
   - Can view all users in the system
   - Can promote/demote users to/from admin status
   - Cannot revoke their own admin privileges

## Admin Implementation

The admin role is implemented by:

1. An `admin` boolean field on the `User` model (default: false)
2. JWT tokens that include the admin status in their payload
3. Controller-level authorization checks for admin-only actions
4. A consistent authentication strategy via a base controller

## Setting Up an Admin User

Use the provided rake task:

```bash
rails users:create_admin ADMIN_EMAIL=admin@example.com ADMIN_PASSWORD=yourpassword
```

Or manually via Rails console:

```ruby
user = User.find_or_initialize_by(email: 'admin@example.com')
user.password = 'password'
user.password_confirmation = 'password'
user.admin = true
user.save!
```

## Development

### Running Tests

```bash
rails test
```

### Security Considerations

- JWT tokens expire after 24 hours
- Admin status is verified server-side for all admin actions
- Admin users cannot revoke their own admin privileges

## ActiveAdmin

This application also includes the ActiveAdmin gem, which provides a separate admin interface at `/admin`. This is entirely separate from the custom admin role implementation, which is designed to work with the frontend application.
