# frozen_string_literal: true

class SiteController < ApplicationController # rubocop:todo Style/Documentation
  def index
    @props = {
      logo: '/images/Bicker-logo.svg',
      name: 'Bicker'
    }
  end
end
