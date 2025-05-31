class ApplicationController < ActionController::API
  include Pagy::Backend

  def route_not_found
    render json: { error: "Endpoint not found" }, status: :not_found
  end
end
