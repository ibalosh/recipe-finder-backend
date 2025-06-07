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

    # Build a WHERE clause like "raw_text ILIKE ? OR raw_text ILIKE ? ..."
    # and matching bind values ["%egg%", "%eggs%", …]
    where_clause = terms.map { "raw_text ILIKE ?" }.join(" OR ")
    values = terms.map { |term| "%#{term.downcase}%" }

    # Sub-query to count total ingredient rows per recipe
    totals_sql = Ingredient.select("recipe_id, COUNT(*) AS total_ingredients").group(:recipe_id).to_sql

    # Main sub-query:
    # - JOIN totals to get total_ingredients
    # - Filter ingredients by search terms
    # - COUNT(*) = matched_ingredients
    # - Compute relevance % = matched_ingredients / total_ingredients * 100
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
