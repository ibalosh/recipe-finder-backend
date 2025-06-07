require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      puts auth_headers
      get "/", headers: auth_headers
      expect(response).to have_http_status(:success)
    end

    it "returns authentication failed http status" do
      get "/"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
