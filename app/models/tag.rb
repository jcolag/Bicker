# frozen_string_literal: true

# Model for tags
class Tag < ApplicationRecord
  belongs_to :user
  belongs_to :paragraph
end
