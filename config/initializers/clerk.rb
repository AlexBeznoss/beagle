Clerk.configure do |c|
  c.api_key = ENV["CLERK_SECRET_KEY"]
  c.middleware_cache_store = Rails.cache
  c.logger = Logger.new($stdout)
  c.excluded_routes = ["/health/*"]
end
