# Marduk

## Installation

gem 'marduk', git: 'https://github.com/toboter/marduk.git'
gem 'omniauth-oauth2'

rails marduk_engine:install:migrations
rails db:migrate

add 'include Marduk' to ApplicationController

add 'shareable owner: :record_creator' to any resource for sharing



you need 'record_creator_id' and 'record_publisher_id' on the shareable resource
"belongs_to :record_creator, class_name: 'User'"
"@instance.record_creator = current_user" needs to be added to the controller create method.