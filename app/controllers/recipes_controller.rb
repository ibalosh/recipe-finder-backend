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
      recipes: recipes.map { |r| format_recipe(r) },
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

    render json: format_recipe(recipe)
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

  def search_param_terms
    search_param.to_s.strip.downcase.split(/\s+/)
  end

  def format_recipe(recipe)
    {
      id: recipe.id,
      title: recipe.title,
      prep_time: recipe.prep_time,
      cook_time: recipe.cook_time,
      ratings: recipe.ratings,
      image_url: recipe.image_url,
      author: recipe.author&.name,
      category: recipe.category&.name,
      cuisine: recipe.cuisine&.name,
      ingredients: recipe.ingredients.map(&:raw_text)
    }
  end
end
