Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/signout', to: 'sessions#destroy', as: 'signout'
  put '/set_per_page', to: 'sessions#set_per_page'
  # resources :users, except: :show, path: '/admin/users'

  resources :users, path: '/admin/users' do
    get 'add_token_to_babili', to: 'users#add_token_to_babili', on: :collection
    get 'settings', to: 'users#settings', on: :collection
  end
end
