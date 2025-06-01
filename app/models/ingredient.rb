class Ingredient < ApplicationRecord
  belongs_to :recipe

  # Finds recipes by matching any of the provided search terms against ingredient text.
  # Returns recipe_ids with the number of matching ingredients per recipe.
  def self.matching_recipe_ids_by_ingredients_count(terms)
    return none if terms.blank?

    where_clauses = terms.map { "raw_text ILIKE ?" }.join(" OR ")
    values = terms.map { |term| "%#{term}%" }

    where(where_clauses, *values)
      .select(:recipe_id, "COUNT(*) AS match_count")
      .group(:recipe_id)
  end
end
