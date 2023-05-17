module Middlewares
  class PrimaryRegionReply
    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) if in_primary_region?
      return @app.call(env) if env["REQUEST_METHOD"] == "GET"

      res = Rack::Response.new(
        "",
        409,
        {"Fly-Replay" => "region=#{ENV.fetch("PRIMARY_REGION")};state=http_method"}
      )
      res.finish
    end

    private

    def in_primary_region?
      ENV.fetch("FLY_REGION") == ENV.fetch("PRIMARY_REGION")
    end
  end
end
