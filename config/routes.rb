Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/signout', to: 'sessions#destroy', as: 'signout'
  put '/set_per_page', to: 'sessions#set_per_page'
  resources :users, exceot: :show, path: '/admin/users'

  resource :user, only: :show do
    get 'add_token_to_babili', to: 'users#add_token_to_babili'
  end
end
