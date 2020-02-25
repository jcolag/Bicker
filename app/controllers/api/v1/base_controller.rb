# frozen_string_literal: true

# rubocop:todo Style/Documentation
module Api
  module V1
    class BaseController < ApplicationController
      respond_to :json
    end
  end
end
# rubocop:enable Style/Documentation
