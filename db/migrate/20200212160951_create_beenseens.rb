# frozen_string_literal: true

# rubocop:todo Style/Documentation
class CreateBeenseens < ActiveRecord::Migration[6.0]
  def change
    create_table :beenseens do |t|
      t.references :paragraph, null: false, foreign_key: {
        to_table: :paragraphs
      }
      t.references :user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
# rubocop:enable Style/Documentation
