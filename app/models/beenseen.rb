# frozen_string_literal: true

# The user-has-seen-paragraph model
class Beenseen < ApplicationRecord
  belongs_to :user
  belongs_to :paragraph
end
