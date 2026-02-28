class CreateAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.references :workspace, null: false, foreign_key: true
      t.string :name
      t.text :soul_md
      t.text :agents_md
      t.text :memory_md
      t.text :heartbeat_md
      t.string :status, default: "stopped"

      t.timestamps
    end

    add_index :agents, :status
  end
end
