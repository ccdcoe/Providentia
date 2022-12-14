# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    delete 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  resources :exercises, only: %i[new create show edit update] do
    resource :map, only: %i[show]
    resources :virtual_machines, except: %i[edit] do
      resources :network_interfaces, path: 'nics', only: %i[new create update destroy] do
        resources :addresses, only: %i[create update destroy]
      end
    end
    resources :networks do
      resources :address_pools
    end
    resources :services, except: :edit do
      resources :service_checks, only: %i[create update destroy]
      resources :special_checks, only: %i[create update destroy]
    end
    resources :capabilities
  end

  resources :operating_systems, except: %i[edit destroy] do
    post 'merge', on: :collection
  end

  resources :api_tokens, except: %i[show edit update]
  resources :versions, only: %i[index show]

  get 'docs/api', to: 'docs#api'
  get 'docs/templating', to: 'docs#templating'

  namespace :api, defaults: { format: :json } do
    namespace :v2 do
      resources :exercises, only: :show do
        resource :networks, only: :show
      end
    end

    namespace :v3 do
      resources :exercises, path: '', only: %i[index show] do
        resources :networks, only: %i[index show]
        resources :services, only: %i[index show]
        resources :capabilities, only: %i[index]
        resources :tags, only: %i[index]
        resource :inventory, only: %i[show]
        resource :graph, only: %i[show]
        resources :virtual_machines, path: 'hosts', only: %i[index show]
      end
    end
  end

  root to: 'dashboard#index'
end
