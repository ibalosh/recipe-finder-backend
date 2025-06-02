class RecipesController < ApplicationController
  def index
    if search_param.present? && search_param_terms.present?
      @pagy, recipes = pagy(Recipe.matching_ingredients(search_param_terms))
    else
      @pagy, recipes = pagy(Recipe.includes(:author, :category, :cuisine, :ingredients))
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

  def search_param
    params[:q]
  end

  def search_param_terms
    search_param.to_s.strip.downcase.split(/\s+/).flat_map { |t| [ t.singularize, t.pluralize ] }.uniq
  end

  def format_recipe(recipe)
    {
      id: recipe.id,
      title: recipe.title,
      prep_time: recipe.prep_time,
      cook_time: recipe.cook_time,
      ratings: recipe.ratings,
      image_url: recipe.image_url,
      author: recipe.author_name,
      category: recipe.category&.name,
      cuisine: recipe.cuisine_name,
      ingredients: recipe.ingredients.map(&:raw_text)
    }
  end
end
