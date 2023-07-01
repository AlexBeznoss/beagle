module Middlewares
  class DatabaseSelector
    def initialize(app, resolver_klass = nil, context_klass = nil, options = {})
      @app = app
      @resolver_klass = resolver_klass || ::ActiveRecord::Middleware::DatabaseSelector::Resolver
      @context_klass = context_klass || ::ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
      @options = options
    end

    def call(env)
      request = ActionDispatch::Request.new(env)

      select_database(request) do
        @app.call(env)
      end
    end

    private

    def select_database(req, &blk)
      context = @context_klass.call(req)
      resolver = @resolver_klass.call(context, @options)

      response = if reading_request?(req)
        resolver.read(&blk)
      else
        resolver.write(&blk)
      end

      resolver.update_context(response)
      response
    end

    def reading_request?(req)
      (req.get? || req.head?) && !admin?(req)
    end

    def admin?(req)
      req.path.match?(/^\/admin/)
    end
  end
end
