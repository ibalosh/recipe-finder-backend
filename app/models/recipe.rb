class Recipe < ApplicationRecord
  belongs_to :author, optional: true
  belongs_to :category, optional: true
  belongs_to :cuisine, optional: true
  has_many :ingredients

  def author_name
    author&.name || "deleted-user"
  end

  def cuisine_name
    cuisine&.name || ""
  end

  def self.matching_ingredients(terms)
    matches = Ingredient.matching_recipe_ids_by_ingredients_count(terms)

    joins("JOIN (#{matches.to_sql}) AS matches ON recipes.id = matches.recipe_id")
      .select("recipes.*, matches.match_count")
      .includes(:author, :category, :cuisine, :ingredients)
      .order("matches.match_count DESC")
  end
end
