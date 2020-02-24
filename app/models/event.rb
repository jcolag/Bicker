class Event < ApplicationRecord # rubocop:todo Style/Documentation
  belongs_to :user
  belongs_to :message
end
