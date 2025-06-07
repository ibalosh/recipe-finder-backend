require 'rails_helper'

RSpec.describe 'GET /recipes', type: :request do
  describe 'search by ingredients' do
    before do
      create(:recipe, title: 'French Toast', ingredients: %w[eggs milk sugar vanilla])
      create(:recipe, title: 'Pancakes', ingredients: %w[eggs milk flour])
      create(:recipe, title: 'Omelette', ingredients: %w[eggs milk])
      create(:recipe, title: 'Rice Bowl', ingredients: %w[rice soy sauce])
    end

    it 'returns recipes sorted by relevance' do
      get '/recipes', headers: auth_headers, params: { search: 'eggs milk sugar' }

      expect(response).to have_http_status(:ok)
      titles = JSON.parse(response.body)["recipes"].map { |r| r["title"] }
      expect(titles).to eq([ 'Omelette', 'French Toast', 'Pancakes' ])
    end

    it 'returns empty array if no ingredients match' do
      get '/recipes', headers: auth_headers, params: { search: 'banana' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["recipes"]).to eq([])
    end

    it 'returns all recipes if search param is missing' do
      get '/recipes', headers: auth_headers

      expect(response).to have_http_status(:ok)
      parsed = JSON.parse(response.body)
      expect(parsed["recipes"].size).to eq(4)
    end
  end

  describe 'pagination' do
    it 'returns first 10 recipes by default pagination' do
      15.times { |i| create(:recipe, title: "Recipe #{i + 1}", ingredients: %w[egg milk]) }

      get '/recipes', headers: auth_headers, params: { search: 'egg', page: 1 }

      expect(response).to have_http_status(:ok)
      parsed = JSON.parse(response.body)

      aggregate_failures do
        expect(parsed["recipes"].size).to eq(10)
        expect(parsed["recipes"].first["title"]).to eq("Recipe 1")
        expect(parsed["recipes"].last["title"]).to eq("Recipe 10")

        expect(parsed["pagination"]).
          to include(
               "current_page" => 1,
               "total_count" => 15,
               "total_pages" => 2,
               "next_page" => 2,
               "prev_page" => nil
             )
      end
    end

    it 'returns second page with remaining results' do
      15.times { |i| create(:recipe, title: "Recipe #{i + 1}", ingredients: %w[egg milk]) }

      get '/recipes', headers: auth_headers, params: { search: 'egg', page: 2 }

      parsed = JSON.parse(response.body)

      aggregate_failures do
        expect(parsed["recipes"].size).to eq(5)
        expect(parsed["recipes"].first["title"]).to eq("Recipe 11")

        expect(parsed["pagination"]).
          to include(
               "current_page" => 2,
               "next_page" => nil,
               "prev_page" => 1
          )
      end
    end

    it 'respects custom per_page parameter' do
      12.times { |i| create(:recipe, title: "Recipe #{i + 1}", ingredients: %w[egg]) }

      get '/recipes', headers: auth_headers, params: { search: 'egg', page: 1, per_page: 5 }

      parsed = JSON.parse(response.body)
      expect(parsed["recipes"].size).to eq(5)
      expect(parsed["pagination"]["total_pages"]).to eq(3)
    end
  end
end
