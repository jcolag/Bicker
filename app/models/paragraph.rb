class Paragraph < ApplicationRecord
  belongs_to :message
  belongs_to :parent
  belongs_to :next
  belongs_to :user
end
