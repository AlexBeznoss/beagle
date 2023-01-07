class HoneybadgerTokenAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    token = env["HTTP_HONEYBADGER_TOKEN"]
    etoken = Rails.application.credentials.honeybadger.header
    return unauthorized(env) if !token || token != etoken

    status, headers, response = @app.call(env)

    [status, headers, response]
  end

  private

  def unauthorized(env)
    content_type = env["HTTP_ACCEPT"]
    is_json = content_type == "application/json"

    ["401", {"Content-Type" => content_type}, [is_json ? {}.to_json : ""]]
  end
end
