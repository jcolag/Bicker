# frozen_string_literal: true

# Fix the messages.subject column
class RequireMessageInfo < ActiveRecord::Migration[6.0]
  def change
    change_column :messages, :subject, :string, null: false
  end
end
