class Recipe < ApplicationRecord
  belongs_to :author, optional: true
  belongs_to :category, optional: true
  belongs_to :cuisine, optional: true
  has_many :ingredients

  validates :instructions, presence: true, length: { minimum: 5 }

  # Find recipes ranked by how well their ingredients match the given search terms.
  #
  # @param terms [Array<String>] a list of ingredient tokens (e.g. %w[eggs mushroom])
  # @return [ActiveRecord::Relation] recipes with two extra attributes:
  #   - matched_ingredients   Integer count of ingredient-rows matching any term
  #   - relevance             Float percentage match (matches / total_ingredients * 100)
  #
  # Results are ordered first by highest relevance %, then by highest match ingredient count.
  def self.matching_by_ingredients(terms)
    return none if terms.blank?
    terms = terms.flat_map { |t| [ t.singularize, t.pluralize ] }.uniq

    # Build the subquery we defined on Ingredient
    matches = Ingredient.relevance_ranked_for(terms)

    joins("JOIN (#{matches.to_sql}) AS matches ON recipes.id = matches.recipe_id")
      .select("recipes.*, matches.relevance, matches.matched_ingredients")
      .order("matches.relevance DESC, matches.matched_ingredients DESC")
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
      base[:short_description] = short_description
      base[:instructions] = instructions
    end

    base
  end
end
