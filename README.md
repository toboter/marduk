# Marduk

Marduk defines common models for babylon-online applications. 
It adds a User and a assocciated Group model. As well as an omniauth strategy for babili 
and a session controller along with the routes needed. 

# Installation
To use `Marduk` in your application, add this line to your Gemfile:

```ruby
  gem 'marduk', git: 'https://github.com/toboter/marduk.git'
```

After add it, run `bundle install`.

Next you need to load the migrations of this gem, execute in your Rails application:

```
rails marduk_engine:install:migrations
rails db:migrate
```

You will have to set several keys in `secrets.yml`
  client_id: 6ea29b740d8f6aee3e1acb9261d169a06b8409e926ca59a49e1d887e1bac71eb
  client_secret: 8bc94fae6babf7d49c81d232db7e9de423373af99dc3c60ce89eb636da0dc2e3
  provider_site: http://localhost:3000
  host: http://localhost:3001


Last step is to include `Marduk`.

```ruby
# File app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include Marduk

  #...
end
```


# Usage

## LogIn / LogOut helpers
```ruby
<%= link_to fa_icon('sign-in', text: "Sign in through Bab-ili"), "/auth/babili" %>

<%= link_to fa_icon('sign-out', text: "Sign Out"), signout_path %>
```
## User administration
```ruby
<%= link_to(fa_icon('users', text: "Users"), users_path) %>
```

## Title helper
`yield(:title) if @show_header` in applkication.html.erb will be filled with `<% title "Subjects", show_header = true %>` out of any shown view.



Example:
```ruby
# File app/views/layouts/application.html.erb
<!DOCTYPE html>
<html>
  <head>
    <title><%= content_for?(:title) ? yield(:title) : 'literature.babylon-online.org' %></title>
    #...
  </head>
  <body>
    #...
    <% if current_user %> 
      <li class="dropdown" style="margin-left:20px;">
        <p class="navbar-text dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
          <%= fa_icon('user', text: "#{current_user.try(:name)}") %>
          <span class="caret"></span>
        </p>
        <ul class="dropdown-menu">
          <%= content_tag :li, link_to(fa_icon('cog', text: "Settings"), ''), class: 'disabled' %>
          <%= content_tag :li, link_to(fa_icon('users', text: "Users"), users_path) if current_user.is_admin? %>
          <li role="separator" class="divider"></li>        
          <li><%= link_to fa_icon('sign-out', text: "Sign Out"), signout_path %></li>
        </ul>
      </li>
    <% else %>
      <li><%= link_to fa_icon('sign-in', text: "Sign in through Bab-ili"), "/auth/babili" %></li>
    <% end %>
    #...
  </body>
```

# Helper methods on current_user
* `can_administrate?`
* `can_comment?`
* `can_create?`
* `can_publish?`

# User instance methods
* `is_owner?(resource)`
* `is_admin?`