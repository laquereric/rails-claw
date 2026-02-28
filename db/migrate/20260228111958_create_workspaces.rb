class CreateWorkspaces < ActiveRecord::Migration[8.1]
  def change
    create_table :workspaces do |t|
      t.string :name
      t.string :path
      t.string :status, default: "stopped"
      t.integer :picoclaw_pid
      t.json :config, default: {}

      t.timestamps
    end

    add_index :workspaces, :name, unique: true
    add_index :workspaces, :status
  end
end
