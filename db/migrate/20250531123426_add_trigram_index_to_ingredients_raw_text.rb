class AddTrigramIndexToIngredientsRawText < ActiveRecord::Migration[8.0]
  def change
    add_index :ingredients, :raw_text, using: :gin, opclass: :gin_trgm_ops, name: 'index_ingredients_on_raw_text_trgm'
  end
end
