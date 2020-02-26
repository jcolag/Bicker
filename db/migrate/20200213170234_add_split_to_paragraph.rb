# frozen_string_literal: true

# Add a has-been-split field to paragraphs
class AddSplitToParagraph < ActiveRecord::Migration[6.0]
  def change
    add_column :paragraphs, :split, :boolean, null: false, default: false
  end
end
