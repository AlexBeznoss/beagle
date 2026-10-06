Rails.application.routes.draw do
  root "job_posts#index"

  get "search", to: "job_posts#search", as: :search
  get "health/:provider/check", to: "health#show"
  get "health/fly", to: "health#fly"

  direct :cfl_blob do |blob|
    if Rails.env.production?
      File.join(Rails.application.credentials.dig(:cloudflare, :cdn_host), blob.key)
    else
      route_for(:rails_blob, blob)
    end
  end
end
