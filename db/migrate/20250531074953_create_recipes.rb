class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes do |t|
      t.string :title, null: false
      t.integer :cook_time, null: false
      t.integer :prep_time, null: false
      t.decimal :ratings, null: false, precision: 10, scale: 2, default: 0
      t.string :image_url, null: false
      t.references :author, foreign_key: { on_delete: :nullify }, null: true
      t.references :category, foreign_key: { on_delete: :nullify }, null: true
      t.references :cuisine, foreign_key: { on_delete: :nullify }, null: true

      t.timestamps
    end
  end
end
