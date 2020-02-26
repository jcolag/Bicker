# frozen_string_literal: true

# The site controller, obviously
class SiteController < ApplicationController
  def index
    @props = {
      logo: '/images/Bicker-logo.svg',
      name: 'Bicker'
    }
  end
end
