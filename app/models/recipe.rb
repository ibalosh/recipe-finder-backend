class Recipe < ApplicationRecord
  belongs_to :author, optional: true
  belongs_to :category, optional: true
  belongs_to :cuisine, optional: true
  has_many :ingredients

  # Returns recipes ordered by how many of their ingredients match the given search terms.
  #
  # Relevance is calculated as the percentage of a recipe's ingredients
  # that match the search terms. For example, if a recipe has 4 ingredients
  # and 2 match the search terms, its relevance is 50%.
  #
  # It will also look for singular and plural matches.
  #
  # Example usage:
  #   Recipe.matching_by_ingredients(["milk", "eggs", "sugar"])
  def self.matching_by_ingredients(terms)
    return none if terms.blank?
    terms = terms.flat_map { |t| [ t.singularize, t.pluralize ] }.uniq

    matches = Ingredient.relevance_ranked_for(terms)

    joins("JOIN (#{matches.to_sql}) AS matches ON recipes.id = matches.recipe_id")
      .select("recipes.*, matches.relevance")
      .order("matches.relevance DESC")
  end

  def as_json(options = {})
    base = super({
      only: [ :id, :title, :ratings, :image_url, :cook_time, :prep_time ]
    }.merge(options))

    base[:author] = author && { id: author.id, name: author.name }
    base[:category] = category && { id: category.id, name: category.name }
    base[:ingredients] = ingredients.map(&:raw_text)

    if options[:detailed]
      base[:cuisine]    = cuisine && { id: cuisine.id, name: cuisine.name }
    end

    base
  end
end
