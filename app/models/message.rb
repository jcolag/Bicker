class Message < ApplicationRecord
  belongs_to :category
  belongs_to :user
  belongs_to :paragraph
end
