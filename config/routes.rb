Rails.application.routes.draw do
  devise_for :users, only: :omniauth_callbacks, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  # ---- ADMIN ----
  namespace :admin do
    resources :ads
    get 'suivi_references/index'
    get 'validation/index'
    get 'feedbacks/index'
    get 'reports/index'
    get 'users/index'
    get 'oeuvres/index'
    get 'dashboard/index'
    root to: "dashboard#index"
    get "dashboard", to: "dashboard#index"
    get "suivi_references", to: "dashboard#suivi_references"
    get "suivi_lists", to: "dashboard#suivi_lists"
    get "feedbacks", to: "dashboard#feedbacks"
    resources :etablissements, only: [:index, :edit, :update, :destroy]
  end

  get 'frise/oeuvres', to: 'search#frise_oeuvres'


  # ---- LOCALISATION ----
  scope "(:locale)", locale: /fr|en/ do

    # Racine par défaut
    root 'oeuvres#index'

    # Routes Devise
    devise_for :users, skip: :omniauth_callbacks, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations',
      passwords: 'users/passwords'
    }

    devise_scope :user do
      get 'users/sign_out', to: 'users/sessions#destroy'
      get 'users/oauth_reauthentication', to: 'users/registrations#oauth_reauthentication', as: :oauth_reauthentication
      get 'users/:id/visits', to: 'users#visits', as: :user_visits
      delete 'users/unlink_provider', to: 'users/registrations#unlink_provider', as: :unlink_provider
    end
    # Tes routes publiques
    resources :feedbacks, only: [:new, :create, :index, :destroy]
    resources :users, only: [:index] do
      member do
        patch :ban
        patch :unban
        patch :certify
        patch :uncertify
        post :admin_resend_confirmation
      end
    end
    
    get 'notifications/new', to: 'notifications#new', as: :notifications_new
    resources :notifications, only: [:index, :show, :destroy, :new, :create]

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
        post 'add_studio'
        post 'remove_studio'
        get :load_more_studios
      end
      get :load_more_oeuvres, on: :collection
      get :load_more_designers, on: :collection
      get :load_more_studios, on: :collection
      collection do
        get :search_items
      end
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

    resources :studios, param: :slug do
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

    # Pages statiques
    get '/search_autocomplete', to: 'search#autocomplete'
    get 'search', to: 'search#search', as: 'search'
    get 'parrainage', to: 'pages#parrainage', as: 'parrainage'
    get 'kit-presse', to: 'pages#kit-presse', as: 'kit-presse'
    get 'donateurs', to: 'pages#donateurs', as: 'donateurs'
    get 'plan-site', to: 'pages#plan-site', as: 'plan-site'
    get 'presentation', to: 'pages#presentation', as: 'presentation'
    get 'add_elements', to: 'pages#add_elements', as: 'add_elements'
    get 'profil', to: 'pages#profil', as: 'profil'
    get 'validation', to: 'pages#validation', as: 'validation'
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

    #ADS
    resources :ads, only: [] do
      member do
        get :click      # Pour tracker le clic
        get :impression # Pour tracker l'affichage
      end
    end 

    post '/api/devices', to: 'api/devices#create'

    # ---- ERREURS ----
    match "/404", to: "errors#not_found", via: :all
    match "/500", to: "errors#internal_server_error", via: :all
    match "/422", to: "errors#unprocessable_entity", via: :all
    match "/403", to: "errors#forbidden", via: :all

  end


  # Healthcheck
  get 'up', to: 'rails/health#show', as: :rails_health_check
end
