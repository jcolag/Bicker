class RequireMessageInfo < ActiveRecord::Migration[6.0]
  def change
    change_column :messages, :subject, :string, null: false
  end
end
