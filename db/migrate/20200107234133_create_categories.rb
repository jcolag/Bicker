# frozen_string_literal: true

# Create the categories table
class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :name, { null: false }
      t.string :of, { default: 'message' }
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
