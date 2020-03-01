# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteController, type: :controller do
  describe 'GET index' do
    it "returns HTTP success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns @props" do
      props = {
        logo: '/images/Bicker-logo.svg',
        name: 'Bicker'
      }
      get :index
      expect(assigns(:props)).to eq(props)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end
end
