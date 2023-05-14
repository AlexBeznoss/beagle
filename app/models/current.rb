class Current < ActiveSupport::CurrentAttributes
  CACHE_TLD = 60

  attribute :session_claims, :user_id, :session_id
  attribute :session, :user

  def session_claims=(session)
    super
    self.user_id = session["sub"]
    self.session_id = session["sid"]
  end

  def user
    attributes[:user] ||= Rails.cache.fetch("clerk_user:#{user_id}", expires_in: CACHE_TLD) do
      sdk.users.find(user_id)
    end
  end

  def session
    attributes[:session] ||= sdk.sessions.find(session_id)
  end

  def verified?
    !!session_id
  end

  private

  def sdk
    Clerk::SDK.new
  end
end
