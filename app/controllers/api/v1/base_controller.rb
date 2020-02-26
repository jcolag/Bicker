# frozen_string_literal: true

# API namespace
module Api
  module V1
    # Superclass for API controllers
    class BaseController < ApplicationController
      respond_to :json
    end
  end
end
