require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  describe '.relevance_ranked_for' do
    it 'returns none if search terms are blank' do
      result = Ingredient.relevance_ranked_for([])
      expect(result).to eq(Ingredient.none)
    end

    it 'returns relevance data for matching ingredients' do
      recipe = create(:recipe, title: 'Test Recipe', ingredients: %w[eggs milk sugar vanilla])
      data = Ingredient.relevance_ranked_for(%w[eggs sugar]).find_by(recipe_id: recipe.id)

      aggregate_failures do
        expect(data.matched_ingredients).to eq(2)
        expect(data.total_ingredients).to eq(4)
        expect(data.relevance.to_f).to eq(50.0)
      end
    end

    it 'returns 100% relevance when all ingredients match' do
      recipe = create(:recipe, title: 'Exact Match', ingredients: %w[eggs milk])
      data = Ingredient.relevance_ranked_for(%w[eggs milk]).find_by(recipe_id: recipe.id)

      expect(data.relevance.to_f).to eq(100.0)
    end

    it 'ignores non-matching recipes' do
      create(:recipe, title: 'Unmatched', ingredients: %w[flour butter salt])
      data = Ingredient.relevance_ranked_for(%w[eggs milk])

      expect(data).to be_empty
    end

    it 'includes recipes even with duplicated matching ingredients' do
      recipe = create(:recipe, title: 'Repeats', ingredients: %w[egg egg sugar])
      data = Ingredient.relevance_ranked_for(%w[egg sugar]).find_by(recipe_id: recipe.id)

      aggregate_failures do
        expect(data.matched_ingredients).to eq(3) # matches all 3 lines
        expect(data.total_ingredients).to eq(3)
        expect(data.relevance.to_f).to eq(100.0)
      end
    end
  end
end
