require "clerk/authenticatable"

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Clerk::Authenticatable
  before_action :assign_current_session
  protect_from_forgery with: :exception

  layout -> { ApplicationLayout unless turbo_frame_request? }

  private

  def assign_current_session
    claims = clerk_verified_session_claims
    return unless claims

    Current.session_claims = claims
  end

  def require_signin!
    return if Current.verified?

    redirect_to root_path, alert: t("login_warning")
  end
end
