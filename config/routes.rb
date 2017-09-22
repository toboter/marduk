Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/signout', to: 'sessions#destroy', as: 'signout'
  put '/set_per_page', to: 'sessions#set_per_page'
  # resources :users, except: :show, path: '/admin/users'

  resources :users, path: '/admin/users' do
    get 'add_token_to_babili', to: 'users#add_token_to_babili', on: :collection
    get 'get_accessibilities', to: 'users#update_accessibilities', on: :collection
    get 'settings', to: 'users#settings', on: :collection
  end

  namespace :api do
    scope :hooks do
      get 'update_accessibilities', to: 'webhooks#update_user_accessibilities'
      get 'upload_local_user_token', to: 'webhooks#add_token_to_babili'
    end
  end
end
