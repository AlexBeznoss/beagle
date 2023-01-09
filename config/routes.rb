Rails.application.routes.draw do
  with_honeybadger_auth =
    lambda do |app|
      Rack::Builder.new do
        use HoneybadgerTokenAuth
        run app
      end
    end

  mount with_honeybadger_auth.call(HealthMonitor::Engine), at: "health"
  mount Sidekiq::Web => "admin/sidekiq"

  root "job_posts#index"

  get "search", to: "job_posts#search", as: :search
end
