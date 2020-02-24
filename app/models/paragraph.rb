class Paragraph < ApplicationRecord # rubocop:todo Style/Documentation
  belongs_to :message
  belongs_to :parent, optional: true
  belongs_to :next, optional: true
  belongs_to :user
end
