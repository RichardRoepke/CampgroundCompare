module UserHelper

  def is_active(action)
    return 'active' if params[:action] == action
  end
end
