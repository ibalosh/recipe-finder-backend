module RequestSpecHelper
  def auth_headers
    { 'X-API-Token' => "test" }
  end
end
