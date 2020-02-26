# frozen_string_literal: true

# Create the users table
class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :login
      t.string :email
      t.string :crypted_password
      t.string :salt
      t.string :remember_token
      t.datetime :remember_token_expires_at

      t.timestamps
    end
  end
end
