class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.references :user, null: false, foreign_key: true, :null => false
      t.references :paragraph, null: false, foreign_key: true, :null => false
      t.string :word, :null => false

      t.timestamps
    end
  end
end
