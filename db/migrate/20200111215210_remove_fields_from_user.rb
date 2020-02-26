# frozen_string_literal: true

# Remove useless/obsolete fields from the user model
class RemoveFieldsFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :email
    remove_column :users, :crypted_password
    remove_column :users, :salt
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
  end
end
