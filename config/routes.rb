Rails.application.routes.draw do
  devise_for :admins, controllers: {
    sessions: 'admins/sessions'
  }
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    confirmations: 'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  resources :jobs, only: [:index, :show]
  
  get '/jobs/city/:city_id', to: 'jobs#index', as: 'jobs_with_city'
  get '/jobs/industry/:industry_id', to: 'jobs#index', as: 'jobs_with_industry'
  get '/jobs/company/:company_id', to: 'jobs#index', as: 'jobs_with_company'
  get '/search', to: 'jobs#search', as: 'search_jobs'
  get '/cities/', to: 'cities#index', as: 'cities'
  get '/industries/', to: 'industries#index', as: 'industries'
  get '/history/', to: 'history#index'
  get '/users/info', to: 'users#info'
  get '/users/applied-jobs', to: 'users#apply_jobs'
  get '/users/favorite-jobs', to: 'users#favorite_jobs'
  get '/admins/applies', to: 'admins#applies', as: 'admins_applies'
  get '/pages/404', to: 'pages#page_404', as: 'page_404'

  post '/apply_or_favorite', to: 'users#apply_or_favorite_jobs'

  delete '/remove_favorite_job', to: 'users#remove_favorite_job'
end
