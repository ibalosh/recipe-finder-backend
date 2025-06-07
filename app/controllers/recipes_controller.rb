class RecipesController < ApplicationController
  def index
    if search_param.present? && search_param_terms.present?
      @pagy, recipes = pagy(
        Recipe.matching_by_ingredients(search_param_terms).
          includes(:author, :category, :cuisine, :ingredients),
        limit: items_per_page
      )
    else
      @pagy, recipes = pagy(Recipe.includes(:author, :category, :cuisine, :ingredients), limit: items_per_page)
    end

    render json: {
      recipes: recipes,
      pagination: {
        current_page: @pagy.page,
        next_page:    @pagy.next,
        prev_page:    @pagy.prev,
        total_pages:  @pagy.pages,
        total_count:  @pagy.count
      }
    }
  end

  def show
    recipe = Recipe.includes(:author, :category, :cuisine, :ingredients).find(params[:id])

    render json: recipe.as_json(detailed: true)
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: {
        message: "Recipe not found."
      }
    }, status: :not_found
  end

  private

  def items_per_page
    per_page = params[:per_page]
    return nil unless per_page.present? && per_page.to_s.strip.match?(/\A\d+\z/)

    per_page.to_i
  end

  def search_param
    params[:search]
  end

  # return array of terms which are separated by whitespace
  def search_param_terms
    search_param.to_s.strip.downcase.split(/\s+/)
  end
end
