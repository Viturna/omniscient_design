Rails.application.routes.draw do
  devise_for :users, only: :omniauth_callbacks, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  # ---- ADMIN ----
  namespace :admin do
    resources :ads
    resources :quizzes do
      collection do
        get :stats
        get :sessions
        post :auto_generate
      end
    end
    get 'suivi_references/index'
    get 'validation/index'
    get 'feedbacks/index'
    get 'reports/index'
    get 'users/index'
    get 'references/index'
    get 'references/index' # Pour la redirection SEO
    get 'dashboard/index'
    root to: "dashboard#index"
    get "dashboard", to: "dashboard#index"
    get "suivi_references", to: "dashboard#suivi_references"
    get "suivi_lists", to: "dashboard#suivi_lists"
    get "feedbacks", to: "dashboard#feedbacks"
    resources :etablissements, only: [:index, :edit, :update, :destroy]
    resources :user_badges, only: [:new, :create]

    get 'references/notions', to: 'references#edit_notions', as: :references_notions
    patch 'references/:id/update_notions', to: 'references#update_notions', as: :reference_update_notions
  end

  get 'frise/references', to: 'search#frise_references'
  get 'frise/references', to: 'search#frise_references' # Redirection SEO


  # ---- LOCALISATION ----
  scope "(:locale)", locale: /fr|en/ do

    # Racine par défaut
    root 'references#index'

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
    resources :users, only: [:index, :show] do
      collection do
        get :export_newsletter
      end
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
        post 'add_reference'
        post 'add_reference' # Compatibilité SEO
        post :add_designer
        delete :remove_designer
        delete 'remove_reference', to: 'lists#remove_reference'
        delete 'remove_reference', to: 'lists#remove_reference' # Compatibilité SEO
        post 'toggle_share'
        post 'invite_editors'
        post 'change_role'
        delete 'remove_user'
        post 'toggle_privacy'
        get :load_more_references
        get :load_more_references # Compatibilité SEO
        post :add_studio
        delete :remove_studio
        get :load_more_studios
      end
      get :load_more_references, on: :collection
      get :load_more_references, on: :collection # Compatibilité SEO
      get :load_more_designers, on: :collection
      get :load_more_studios, on: :collection
      collection do
        get :search_items
      end
    end

    get '/shared/:share_token', to: 'lists#shared', as: :shared_list

    resources :references, param: :slug do
      collection do
        get :load_more
        get 'check_existence'
      end
      member do
        delete :destroy
        get :validate
        delete :cancel
        patch :reject
        get :save_modal
      end
    end

    # Redirections SEO 301 - anciennes URLs oeuvres vers nouvelles references
    get '/oeuvres', to: redirect { |params, req| "/#{params[:locale] || 'fr'}/references" }, status: :moved_permanently
    get '/oeuvres/:slug', to: redirect { |params, req| "/#{params[:locale] || 'fr'}/references/#{params[:slug]}" }, status: :moved_permanently

    # Redirections SEO 301 - anciennes URLs references vers nouvelles references
    get '/references', to: redirect { |params, req| "#{req.original_fullpath.gsub(/\/references/, '/references')}" }, status: :moved_permanently
    get '/references/:slug', to: redirect { |params, req| "/#{params[:locale] || 'fr'}/references/#{params[:slug]}" }, status: :moved_permanently

    resources :designers, param: :slug do
      collection do
        get 'load_more'
        get 'check_existence'
      end
      member do
        get :validate
        delete :cancel
        delete :destroy
        patch :reject
        get :save_modal
      end
    end

    resources :studios, param: :slug do
      collection do
        get 'load_more'
        get 'check_existence'
      end
      member do
        get :validate
        delete :cancel
        delete :destroy
        patch :reject
        get :save_modal
      end
    end

    resources :bug_reports, only: [:index, :new, :create, :show, :destroy] do
      patch :update_status, on: :member
    end

    get 'mes-badges', to: 'badges#index', as: :badges
    post 'badges/rate_app', to: 'badges#rate_app', as: :rate_app_badge

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
    get 'training', to: 'pages#training', as: 'training'
    get 'ressources', to: 'pages#ressources', as: 'ressources'
    get 'settings/notifications', to: 'pages#notifications_settings', as: 'notifications_settings'
    patch 'settings/notifications', to: 'pages#update_notifications_settings'
    get 'validation', to: 'pages#validation', as: 'validation'
    get 'export_references', to: 'pages#export_references', as: 'export_references'
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
    get 'secret/legal_found', to: 'pages#secret_badge', as: :secret_badge

    #ADS
    get '/go/:id', to: 'ads#click', as: :partner_click
    get '/pixel/:id/view', to: 'ads#impression', as: :partner_impression

    # ---- QUIZ SYSTEM ----
    get 'jeux', to: 'quizzes#index', as: :quizzes_hub
    get 'classement', to: 'quizzes#leaderboard', as: :leaderboard
    resources :quizzes, only: [:show] do
      post :submit, on: :member
      patch :save_progress, on: :member
      post :generate_from_list, on: :collection
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
