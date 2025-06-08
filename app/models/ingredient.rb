class Ingredient < ApplicationRecord
  belongs_to :recipe

  # Calculates how “relevant” each recipe is to a given set of ingredient search terms.
  #
  # This builds a single SQL sub-query that, for each recipe:
  #   1. Counts how many of the provided terms appear in any of its raw_text rows
  #   2. Counts the total number of ingredient rows it has
  #   3. Computes a percentage match (matched rows / total ingredient per recipe rows * 100)
  #
  # @param terms [Array<String>] a list of tokens (e.g. ["egg","eggs","mushroom","mushrooms"])
  # @return [ActiveRecord::Relation] each record has:
  #   - recipe_id                Integer ID of the recipe
  #   - matched_ingredients      Integer number of rows matching any search term
  #   - total_ingredients        Integer total ingredient rows for that recipe
  #   - relevance                Float percentage of matching rows (0–100)
  #
  # You can JOIN this relation onto Recipe to fetch recipes ordered by relevance.
  def self.relevance_ranked_for(terms)
    return none if terms.blank?

    # Match all terms in raw_text via OR
    where_clause = terms.map { "raw_text ILIKE ?" }.join(" OR ")
    values = terms.map { |term| "%#{term.downcase}%" }

    # Sub-query to count total ingredient rows per recipe
    totals = Ingredient.select("recipe_id, COUNT(*) AS total_ingredients").group(:recipe_id)

    # Main query: matched ingredients + relevance %
    Ingredient
      .select(
        [
          "ingredients.recipe_id",
          "COUNT(*) AS matched_ingredients",
          "totals.total_ingredients",
          "ROUND(COUNT(*) * 100.0 / totals.total_ingredients, 2) AS relevance"
        ].join(", ")
      )
      .joins("JOIN (#{totals.to_sql}) AS totals ON totals.recipe_id = ingredients.recipe_id")
      .where(where_clause, *values)
      .group("ingredients.recipe_id, totals.total_ingredients")
  end
end
