Rails.application.routes.draw do
  root to: 'toppages#index'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'signup', to: 'users#new'
  resources :users, only: [:show, :new, :create, :edit, :update, :destroy]

  get 'prev_day', to: 'diaries#prev_day'
  get 'next_day', to: 'diaries#next_day'
  get 'date/:picked_date', to: 'diaries#select_date', as: 'date'
  resources :diaries
end
