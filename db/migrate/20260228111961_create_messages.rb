class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.string :role
      t.text :content
      t.integer :tokens_used
      t.integer :latency_ms

      t.timestamps
    end
  end
end
