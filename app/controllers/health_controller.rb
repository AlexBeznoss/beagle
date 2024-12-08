class HealthController < ActionController::API
  def show
    if authenticated?
      status = HealthMonitor.check(request: request, params: {providers: [params[:provider]]})
      render json: status.to_json, status: status[:status]
    else
      render json: {}, status: :unauthorized
    end
  end

  def fly
    render json: {started: true}
  end

  private

  def authenticated?
    request.headers["Honeybadger-Token"] ==
      Rails.application.credentials.honeybadger.header
  end
end
