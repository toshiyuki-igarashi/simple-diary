Rails.application.routes.draw do
  root to: 'toppages#index'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'signup', to: 'users#new'
  resources :users, only: [:show, :new, :create]

  get 'prev_day', to: 'diaries#prev_day'
  get 'next_day', to: 'diaries#next_day'
  resources :diaries
end
