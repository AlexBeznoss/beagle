Rails.application.routes.draw do
  mount Sidekiq::Web => "admin/sidekiq"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "job_posts#index"
end
