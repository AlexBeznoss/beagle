class CallOnceLockService
  DEFAULT_TIMEOUT = 30

  def self.call(lock_name, timeout: DEFAULT_TIMEOUT)
    redis = Redis.new(Rails.application.config_for(:redis))
     return unless redis.set(lock_name, true, ex: timeout, nx: true)

    yield
  end
end
