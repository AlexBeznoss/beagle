Clerk.configure do |c|
  c.api_key = ENV["CLERK_SECRET_KEY"]
  c.middleware_cache_store = Rails.cache
end
