module UserHelper

  def is_active(action)
    return 'active' if params[:action] == action
    return ''
  end

  def user_last_login(user)
    return user.updated_at unless user.updated_at == user.created_at
    return 'Has not Logged in Yet'
  end
end
