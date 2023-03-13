class ApplicationController < ActionController::Base
  include Pagy::Backend
  layout -> { ApplicationLayout }
end
