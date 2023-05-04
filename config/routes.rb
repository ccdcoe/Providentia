# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    delete 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  resources :exercises, only: %i[new create show edit update] do
    resource :map, only: %i[show]
    resources :actors, only: %i[edit update]
    resources :virtual_machines, except: %i[edit] do
      resources :customization_specs
      resources :network_interfaces, path: 'nics', only: %i[new create update destroy] do
        resources :addresses, only: %i[create update destroy]
      end
    end
    resources :networks do
      resources :address_pools
    end
    resources :services, except: :edit do
      resources :service_subjects, only: %i[create] do
        resources :conditions, only: %i[create update destroy]
      end

      resources :checks, only: %i[create update destroy]
    end
    resources :capabilities
    resource :clone, only: %i[show create]
  end

  resources :operating_systems, except: %i[edit destroy] do
    post 'merge', on: :collection
  end

  resource :search, only: [:show, :create]

  resources :api_tokens, except: %i[show edit update]
  resources :versions, only: %i[index show]

  get 'docs/api', to: 'docs#api'
  get 'docs/templating', to: 'docs#templating'

  # API
  namespace :api, defaults: { format: :json } do
    namespace :v3 do
      resources :exercises, path: '', only: %i[index show] do
        resources :networks, only: %i[index]
        resources :services, only: %i[index show]
        resources :capabilities, only: %i[index]
        resources :tags, only: %i[index]
        resource :inventory, only: %i[show]
        resource :graph, only: %i[show]
        resources :customization_specs, path: 'hosts', only: %i[index show]
      end
    end
  end

  if Rails.env.development?
    mount RailsPgExtras::Web::Engine, at: 'pg_extras'
  end

  root to: 'dashboard#index'
end
