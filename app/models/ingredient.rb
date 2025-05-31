class Ingredient < ApplicationRecord
  belongs_to :recipe


  def self.matching_recipe_ids_by_terms(terms)
    return none if terms.blank?

    conditions = terms.map { "raw_text ILIKE ?" }.join(" OR ")
    values = terms.map { |t| "%#{t}%" }

    select("recipe_id, COUNT(*) AS match_count")
      .where(conditions, *values)
      .group(:recipe_id)
  end
end
