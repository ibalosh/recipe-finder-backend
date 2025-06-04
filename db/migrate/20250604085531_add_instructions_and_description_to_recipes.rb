class AddInstructionsAndDescriptionToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :instructions, :text
    add_column :recipes, :short_description, :string
  end
end
