class Event < ApplicationRecord
  belongs_to :user
  belongs_to :message
end
