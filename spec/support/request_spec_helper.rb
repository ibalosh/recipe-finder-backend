module RequestSpecHelper
  def auth_headers
    { 'X-API-Token' => Rails.application.credentials.api_token }
  end
end
