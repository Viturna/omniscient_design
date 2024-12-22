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
      delete 'remove_designer', to: 'lists#remove_designer'
      delete 'remove_oeuvre', to: 'lists#remove_oeuvre'
    end
  end

  resources :oeuvres, param: :slug do
    collection do
      get 'search'
      get :load_more
    end

    member do
      delete :destroy
      get :validate
      delete 'cancel'
    end
  end

  resources :designers, param: :slug do
    collection do
      get 'load_more'
    end
    member do
      get :validate
      delete 'cancel'
      delete :destroy
    end
  end
  resources :bug_reports, only: [:index, :new, :create, :show, :destroy] do
    patch :update_status, on: :member
  end
  # Routes pour les pages statiques
  get 'search_category', to: 'pages#search_category', as: 'search_category'
  get 'search_frise', to: 'pages#search_frise', as: 'search_frise'
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

  # Route racine
  root 'oeuvres#index'

  # Health check route
  get 'up', to: 'rails/health#show', as: :rails_health_check
end
