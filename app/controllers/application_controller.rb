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

  def hash_string_to_sym(input_hash)
    result_hash = {}

    input_hash.each do |sym, value|
      if value.is_a?(Hash)
        result_hash[sym.to_sym] = hash_string_to_sym(value)
      elsif value.is_a?(Array)
        result_hash[sym.to_sym] = array_string_to_sym(value)
      else
        result_hash[sym.to_sym] = value
      end
    end

    return result_hash
  end

  def array_string_to_sym(input_hash)
    result_hash = []

    input_hash.each do |value|
      if value.is_a?(Hash)
        result_hash.push hash_string_to_sym(value)
      elsif value.is_a?(Array)
        result_hash.push array_string_to_sym(value)
      else
        result_hash.push value
      end
    end

    return result_hash
  end
end
