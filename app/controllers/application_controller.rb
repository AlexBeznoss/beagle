require "clerk/authenticatable"

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Clerk::Authenticatable
  before_action :assign_current_session

  layout -> { ApplicationLayout }

  private

  def assign_current_session
    claims = clerk_verified_session_claims
    return unless claims

    Current.session_claims = claims
  end
end
