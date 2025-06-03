class Ingredient < ApplicationRecord
  belongs_to :recipe

  # Returns a query result with:
  # - recipe_id
  # - total_ingredients (number of ingredients in the recipe)
  # - matched_ingredients (number of ingredients that match search terms)
  # - relevance (percentage of ingredients matched)
  #
  # This query is used to calculate how relevant each recipe is based on
  # how many of its ingredients match the user-provided search terms.
  def self.relevance_ranked_for(terms)
    return none if terms.blank?

    where_clause = terms.map { "raw_text ILIKE ?" }.join(" OR ")
    values = terms.map { |term| "%#{term.downcase}%" }

    totals_sql = Ingredient.
      select("recipe_id, COUNT(*) AS total_ingredients").
      group(:recipe_id).
      to_sql

    joins("JOIN (#{totals_sql}) AS totals ON totals.recipe_id = ingredients.recipe_id")
      .select(
        :recipe_id,
        "COUNT(*) AS matched_ingredients",
        "totals.total_ingredients",
        "ROUND(COUNT(*) * 100.0 / totals.total_ingredients, 2) AS relevance" # percentage match
      )
      .where(where_clause, *values)
      .group("ingredients.recipe_id, totals.total_ingredients")
  end
end
