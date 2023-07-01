module Middlewares
  class PrimaryRegionReply
    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) if in_primary_region?
      return reply_with("http_method") unless env["REQUEST_METHOD"] == "GET"
      return reply_with("admin") if env["REQUEST_PATH"].match?(/^\/admin/)

      @app.call(env)
    end

    private

    def reply_with(state)
      Rack::Response.new(
        "",
        409,
        {"Fly-Replay" => "region=#{ENV.fetch("PRIMARY_REGION")};state=#{state}"}
      ).finish
    end

    def in_primary_region?
      ENV.fetch("FLY_REGION") == ENV.fetch("PRIMARY_REGION")
    end
  end
end
