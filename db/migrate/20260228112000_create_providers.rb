class CreateProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :api_base
      t.string :api_key
      t.boolean :requires_api_key
      t.string :provider_type

      t.timestamps
    end

    add_index :providers, :name, unique: true
  end
end
