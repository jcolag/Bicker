# rubocop:todo Style/Documentation
class AddSplitToParagraph < ActiveRecord::Migration[6.0]
  def change
    add_column :paragraphs, :split, :boolean, null: false, default: false
  end
end
# rubocop:enable Style/Documentation
