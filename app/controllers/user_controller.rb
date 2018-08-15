class UserController < ApplicationController
  before_action :provide_title, :is_admin?
  #before_action

  def index
    @users = User.all.paginate(page: params[:page], per_page: 12)
  end

  def new
  end

  def edit
    @user = User.find(params[:id])
  end

  def show
    @user = User.find(params[:id])
  end

  def search

  end

  def update

  end

  def destroy
    @user = User.find(params[:id])

    if params[:confirmation] == 'yes'
      email = @user.email
      @user.destroy
      redirect_to user_index_path, alert: 'User ' + email.to_s + ' successfully deleted'
    end
  end

  private
  def provide_title
    @title = 'Users'
  end
end
