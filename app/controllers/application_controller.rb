# frozen_string_literal: true

# Controller for the application
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :null_session

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[login email password])
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: %i[login email password current_password]
    )
  end
end
