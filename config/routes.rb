Rails.application.routes.draw do
  root to: 'toppages#index'

  get 'login', to: 'sessions#new'
  get 'login/:id', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'signup', to: 'users#new'
  resources :users, only: [:show, :new, :create, :edit, :update, :destroy]

  get 'move_date', to: 'diaries#move_date'
  get 'show_diary', to: 'diaries#show_diary'
  resources :diaries, except: [:index]

  get 'download', to: 'diary_forms#download'
  get 'upload', to: 'diary_forms#upload'
  post 'download_file', to: 'diary_forms#download_file'
  post 'upload_file', to: 'diary_forms#upload_file'
  resources :diary_forms, only: [:edit, :update]
end
