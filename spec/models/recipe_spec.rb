require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe '.matching_by_ingredients' do
    it 'orders by percentage of matched ingredients' do
      create(:recipe, title: 'French Toast', ingredients: %w[eggs milk sugar vanilla])
      create(:recipe, title: 'Pancakes', ingredients: %w[eggs milk flour])
      create(:recipe, title: 'Omelette', ingredients: %w[eggs milk])

      results = Recipe.matching_by_ingredients(%w[eggs milk sugar])
      expect(results.map(&:title)).to eq([ 'Omelette', 'French Toast', 'Pancakes' ])
    end

    it 'only includes recipes with at least one matching ingredient' do
      create(:recipe, title: 'Bagel', ingredients: %w[flour yeast salt])
      create(:recipe, title: 'Fruit Smoothie', ingredients: %w[banana milk yogurt])

      results = Recipe.matching_by_ingredients(%w[milk])
      expect(results.map(&:title)).to eq([ 'Fruit Smoothie' ])
    end

    it 'returns recipes with plural ingredient matches for singular search terms' do
      create(:recipe, title: 'Cookie', ingredients: %w[flour raspberry sugar])
      create(:recipe, title: 'Fruit Smoothie', ingredients: %w[banana milk yogurt])

      results = Recipe.matching_by_ingredients(%w[raspberries])
      expect(results.map(&:title)).to eq([ 'Cookie' ])
    end

    it 'includes all matched ingredients, even if repeated in the recipe' do
      create(:recipe, title: 'With Repeats', ingredients: %w[egg eggs egg-white sugar])
      create(:recipe, title: 'No Repeats', ingredients: %w[egg sugar])

      results = Recipe.matching_by_ingredients(%w[egg sugar])
      expect(results.map(&:title)).to eq([ 'With Repeats', 'No Repeats' ])
    end

    it 'returns empty when no ingredients match' do
      create(:recipe, title: 'Rice Bowl', ingredients: %w[rice soy sauce sesame])

      results = Recipe.matching_by_ingredients(%w[egg milk])
      expect(results).to be_empty
    end

    it 'returns empty when search input is blank' do
      create(:recipe, title: 'Toast', ingredients: %w[bread butter])

      results = Recipe.matching_by_ingredients([])
      expect(results).to be_empty
    end
  end
end
