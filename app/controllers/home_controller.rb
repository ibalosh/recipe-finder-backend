class HomeController < ApplicationController
  def index
    render json: { message: "Welcome to the Recipe Finder API" }
  end
end
