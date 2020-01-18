class Paragraph < ApplicationRecord
  belongs_to :message
  belongs_to :parent, optional: true
  belongs_to :next, optional: true
  belongs_to :user
end
