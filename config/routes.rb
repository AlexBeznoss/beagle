require_relative "../app/lib/routes_auth_constraint"

Rails.application.routes.draw do
  root "job_posts#index"

  get "search", to: "job_posts#search", as: :search
  get "health/:provider/check", to: "health#show"
  get "health/fly", to: "health#fly"

  resources :bookmarks, only: %i[index destroy]
  resources :job_posts, only: [] do
    resources :bookmarks, only: %i[create destroy], controller: "job_posts/bookmarks"
  end

  direct :cfl_blob do |blob|
    if Rails.env.production?
      File.join(Rails.application.credentials.dig(:cloudflare, :cdn_host), blob.key)
    else
      route_for(:rails_blob, blob)
    end
  end

  RoutesAuthConstraint.call(self, -> { Current.admin? }) do
    mount Motor::Admin => "/admin"
  end
end
