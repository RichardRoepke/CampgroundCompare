class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def is_admin?
    unless current_user.try(:admin?)
      if current_user.present?
        redirect_to root_path, alert: 'Current user does not have administrative privilages.'
      else
        redirect_to new_user_session_path, alert: 'You need to sign in before continuing.'
      end
    end
  end
end
