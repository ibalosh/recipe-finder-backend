class RecipesController < ApplicationController
  def index
    recipes_scope =
      if search_param.present? && search_param_terms.present?
        if search_by_ingredients
          Recipe.matching_by_ingredients(search_param_terms)
        else
          Recipe.where("title ILIKE ?", "%#{search_param}%").order(id: :desc)
        end
      else
        Recipe.all.order(id: :desc)
      end

    @pagy, recipes = pagy(
      recipes_scope.includes(:author, :category, :cuisine, :ingredients),
      limit: items_per_page
    )

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
    render json: construct_api_error("Recipe not found."), status: :not_found
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

  def search_by_ingredients
    params[:mode].nil? || params[:mode] == "ingredients"
  end

  # return array of terms which are separated by whitespace
  def search_param_terms
    search_param.to_s.strip.downcase.split(/\s+/)
  end
end
