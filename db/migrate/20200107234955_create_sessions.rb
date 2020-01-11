class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.integer :session_id
      t.text :data

      t.timestamps
    end
    add_index :sessions, :id, unique: true
    add_index :sessions, :updated_at
  end
end
