class Tag < ApplicationRecord # rubocop:todo Style/Documentation
  belongs_to :user
  belongs_to :paragraph
end
