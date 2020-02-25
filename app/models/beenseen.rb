# frozen_string_literal: true

class Beenseen < ApplicationRecord # rubocop:todo Style/Documentation
  belongs_to :user
  belongs_to :paragraph
end
