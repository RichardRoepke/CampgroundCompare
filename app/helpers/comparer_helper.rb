module ComparerHelper

  def is_active(action)
    return 'active' if params[:action] == action
    return ''
  end
end
