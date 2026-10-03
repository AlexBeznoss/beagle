class ApplicationController < ActionController::Base
  include Pagy::Method

  protect_from_forgery with: :exception

  layout -> { ApplicationLayout unless turbo_frame_request? }
end
