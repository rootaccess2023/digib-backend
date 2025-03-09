# app/admin/dashboard.rb
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    # Add a welcome panel at the top
    panel "Welcome to Admin Panel" do
      para "Welcome to the administrative backend for your application."
      para "Use the navigation menu above to manage your resources."
    end

    # Create a three-column layout
    columns do
      # First column - Recent Users
      column do
        panel "Recent Users" do
          ul do
            User.order(created_at: :desc).limit(5).map do |user|
              li link_to(user.email, admin_user_path(user))
            end
          end
          strong { link_to "View All Users", admin_users_path }
        end
      end

      # Second column - Statistics
      column do
        panel "Statistics" do
          para "Total Users: #{User.count}"
          para "Total Admin Users: #{AdminUser.count}"
          para "Users created in last week: #{User.where('created_at > ?', 1.week.ago).count}"
        end
      end

      # Third column - Latest Activity
      column do
        panel "Latest Activity" do
          table_for User.order(created_at: :desc).limit(5) do
            column("Email") { |user| link_to(user.email, admin_user_path(user)) }
            column("Joined") { |user| time_ago_in_words(user.created_at) + " ago" }
          end
        end
      end
    end

    # User Growth by Month using standard Rails methods
    panel "User Growth by Month" do
      # For PostgreSQL
      if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
        data = User.select("DATE_TRUNC('month', created_at) as month, COUNT(*) as count")
                   .group("DATE_TRUNC('month', created_at)")
                   .order("month DESC")
                   .limit(6)
                   .map { |r| [r.month.to_date, r.count] }
      # For MySQL
      elsif ActiveRecord::Base.connection.adapter_name == 'Mysql2'
        data = User.select("DATE_FORMAT(created_at, '%Y-%m-01') as month, COUNT(*) as count")
                   .group("DATE_FORMAT(created_at, '%Y-%m-01')")
                   .order("month DESC")
                   .limit(6)
                   .map { |r| [Date.parse(r.month), r.count] }
      # For SQLite or other databases - less efficient but works everywhere
      else
        data = User.all
                   .group_by { |u| u.created_at.beginning_of_month }
                   .map { |month, users| [month, users.count] }
                   .sort.reverse
                   .take(6)
      end
      
      table_for data do
        column("Month") { |row| row[0].strftime("%B %Y") }
        column("Users") { |row| row[1] }
      end
    end
  end
end