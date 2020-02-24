# rubocop:todo Style/Documentation
class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      # rubocop:todo Lint/DuplicateHashKey
      t.references :user, null: false, foreign_key: true, null: false
      # rubocop:enable Lint/DuplicateHashKey
      # rubocop:todo Lint/DuplicateHashKey
      t.references :paragraph, null: false, foreign_key: true, null: false
      # rubocop:enable Lint/DuplicateHashKey
      t.string :word, null: false

      t.timestamps
    end
  end
end
# rubocop:enable Style/Documentation
