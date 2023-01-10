Rails.application.routes.draw do
  mount Sidekiq::Web => "admin/sidekiq"

  root "job_posts#index"

  get "search", to: "job_posts#search", as: :search
  get "health/:provider/check", to: "health#show"
end
