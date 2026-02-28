class CreateModels < ActiveRecord::Migration[8.1]
  def change
    create_table :models do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :name
      t.string :api_model_id
      t.string :model_type
      t.integer :context_window
      t.json :capabilities

      t.timestamps
    end

    add_index :models, :api_model_id
    add_index :models, :name
  end
end
