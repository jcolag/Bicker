# frozen_string_literal: true

# The event model
class Event < ApplicationRecord
  belongs_to :user
  belongs_to :message
end
