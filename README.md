# Marduk

## Installation

gem 'marduk', git: 'https://github.com/toboter/marduk.git'
gem 'omniauth-oauth2'

rails marduk_engine:install:migrations
rails db:migrate

add 'include Marduk' to ApplicationController