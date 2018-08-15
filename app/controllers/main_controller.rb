class MainController < ApplicationController

  def home
  end

  def password
    @user = User.find(current_user.id)
  end
end
