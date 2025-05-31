class RecipesController < ApplicationController
  def index
    if params[:q].present?
      query = params[:q].to_s.strip.downcase
      terms = query.split(/\s+/).flat_map { |t| [ t.singularize, t.pluralize ] }.uniq

      # Build ILIKE OR condition for ingredients
      conditions = terms.map { "LOWER(raw_text) ILIKE ?" }.join(" OR ")
      values = terms.map { |t| "%#{t}%" }

      # Subquery: count how many matching ingredients per recipe
      matching = Ingredient
                   .select("recipe_id, COUNT(*) AS match_count")
                   .where(conditions, *values)
                   .group(:recipe_id)

      # Join that to recipes and order by match_count
      recipes = Recipe
                  .joins("JOIN (#{matching.to_sql}) AS matches ON recipes.id = matches.recipe_id")
                  .select("recipes.*, matches.match_count")
                  .includes(:author, :category, :cuisine, :ingredients)
                  .order("matches.match_count DESC")

      @pagy, recipes = pagy(recipes)
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
    render json: { error: "Recipe not found" }, status: :not_found
  end

  private

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
