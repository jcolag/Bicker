# frozen_string_literal: true

# Create a tag table
class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.references :user, null: false, foreign_key: true
      t.references :paragraph, null: false, foreign_key: true
      t.string :word, null: false

      t.timestamps
    end
  end
end
