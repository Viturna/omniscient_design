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
  resources :quizzes, only: [:index, :show, :new, :create] do
    resources :quiz_results, only: [:create]
  end
  resources :feedbacks, only: [:new, :create, :index, :destroy]
  resources :users, only: [:index] do
    member do
      patch :ban
      patch :unban
    end
  end
  resources :notifications, only: [:index, :show, :destroy]
  resources :countries
  resources :domaines
  resources :lists do
    delete 'remove_oeuvre', on: :member
    delete 'remove_designer', on: :member
    member do
      post 'add_oeuvre'
      post 'add_designer'
    end
  end

  resources :oeuvres do
    collection do
      get 'search'
      get 'load_more'
    end
    member do
      delete :destroy
      get :validate
      delete 'cancel'
    end
  end

  resources :designers do
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
  get 'pages/add_elements', to: 'pages#add_elements', as: 'add_elements'
  get 'pages/profil', to: 'pages#profil', as: 'profil'
  get 'validation', to: 'pages#validation', as: 'validation'
  get 'suivi_references', to: 'pages#suivi_references', as: 'suivi_references'
  get 'mentionslegales', to: 'pages#mentionslegales', as: 'mentionslegales'
  get 'politiquedeconfidentialite', to: 'pages#politiquedeconfidentialite', as: 'politiquedeconfidentialite'
  get 'cookies', to: 'pages#cookies', as: 'cookies'
  get 'changelog', to: 'pages#changelog', as: 'changelog'

  # Route racine
  root 'oeuvres#index'

  # Health check route
  get 'up', to: 'rails/health#show', as: :rails_health_check
end
