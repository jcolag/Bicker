class CreateParagraphs < ActiveRecord::Migration[6.0]
  def change
    create_table :paragraphs do |t|
      t.references :message, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :paragraphs }
      t.references :next, foreign_key: { to_table: :paragraphs }
      t.references :user, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
