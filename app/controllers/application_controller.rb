class ApplicationController < ActionController::API
  before_action :authenticate_api!
  include Pagy::Backend

  def route_not_found
    render json: { error: "Endpoint not found" }, status: :not_found
  end

  private

  def authenticate_api!
    provided_token = request.headers["X-API-Token"]
    expected_token = Rails.application.credentials.api_token

    unless ActiveSupport::SecurityUtils.secure_compare(provided_token.to_s, expected_token.to_s)
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
