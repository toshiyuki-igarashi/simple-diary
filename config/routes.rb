Rails.application.routes.draw do
  root to: 'toppages#index'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'signup', to: 'users#new'
  resources :users, only: [:new, :create]

  get 'prev_day', to: 'diaries#prev_day'
  get 'prev_month', to: 'diaries#prev_month'
  get 'next_day', to: 'diaries#next_day'
  get 'next_month', to: 'diaries#next_month'
  resources :diaries
end
