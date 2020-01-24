class SiteController < ApplicationController
  def index
    @props = {
      logo: '/images/Bicker-logo.svg',
      name: 'Bicker',
    }
  end
end
