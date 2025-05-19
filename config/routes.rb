Rails.application.routes.draw do
  get 'bug_reports/new'
  get 'bug_reports/create'
  get 'bug_reports/index'
  get 'bug_reports/show'
  # Routes Devise
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }

  devise_scope :user do
    get 'users/sign_out', to: 'users/sessions#destroy'
  end

  # Resources
  resources :feedbacks, only: [:new, :create, :index, :destroy]
  resources :users, only: [:index] do
    member do
      patch :ban
      patch :unban
      patch :certify
      patch :uncertify
    end
  end
  resources :notifications, only: [:index, :show, :destroy]

  resources :lists, param: :slug do
    member do
      post 'add_oeuvre'
      post 'add_designer'
      post 'remove_designer'
      post 'remove_oeuvre', to: 'lists#remove_oeuvre'
      post 'toggle_share'
      post 'invite_editors'
      post 'change_role'
      delete 'remove_user'
      post 'toggle_privacy'
      get :load_more_oeuvres
    end
    get :load_more_oeuvres, on: :collection
    get :load_more_designers, on: :collection
  end

  get '/shared/:share_token', to: 'lists#shared', as: :shared_list
  resources :oeuvres, param: :slug do
    collection do
      get :load_more
      get 'check_existence'
    end

    member do
      delete :destroy
      get :validate
      delete 'cancel'
      patch :reject
    end
  end

  resources :designers, param: :slug do
    collection do
      get 'load_more'
      get 'check_existence'
    end
    member do
      get :validate
      delete 'cancel'
      delete :destroy
      patch :reject
    end
  end
  resources :bug_reports, only: [:index, :new, :create, :show, :destroy] do
    patch :update_status, on: :member
  end
  # Routes pour les pages statiques
  get '/search_autocomplete', to: 'search#autocomplete'
  get 'search', to: 'search#search', as: 'search'
  get 'parrainage', to: 'pages#parrainage', as: 'parrainage'
  get 'presentation', to: 'pages#presentation', as: 'presentation'
  get 'add_elements', to: 'pages#add_elements', as: 'add_elements'
  get 'profil', to: 'pages#profil', as: 'profil'
  get 'validation', to: 'pages#validation', as: 'validation'
  get 'suivi_references', to: 'pages#suivi_references', as: 'suivi_references'
  get 'mentionslegales', to: 'pages#mentionslegales', as: 'mentionslegales'
  get 'politiquedeconfidentialite', to: 'pages#politiquedeconfidentialite', as: 'politiquedeconfidentialite'
  get 'cookies', to: 'pages#cookies', as: 'cookies'
  get 'cgu', to: 'pages#cgu', as: 'cgu'
  get 'changelog', to: 'pages#changelog', as: 'changelog'
  get 'parrainage_filleul', to: 'pages#parrainage_filleul', as: 'parrainage_filleul'
  post 'parrainage_filleul', to: 'pages#parrainage_filleul'
  get 'set_theme', to: 'application#set_theme'
  get 'contributions', to: 'contributions#index', as: 'user_contributions'
  get 'confirmation_pending', to: 'pages#confirmation_pending', as: 'confirmation_pending'
  # Route racine
  root 'oeuvres#index'
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/403", to: "errors#forbidden", via: :all
  # Health check route
  get 'up', to: 'rails/health#show', as: :rails_health_check

end
