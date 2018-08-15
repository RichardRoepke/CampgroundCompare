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

    unless @user.id == current_user.id
      if params[:commit] == 'Delete User'
        if params[:confirm] == '1'
          email = @user.email
          @user.destroy
          redirect_to user_index_path, alert: 'User ' + email.to_s + ' successfully deleted'
        else
          flash.now[:alert] = 'User was not deleted due to a lack of confirmation.'
        end
      end
    else
      redirect_to user_index_path, alert: 'Cannot delete currently logged in user.'
    end
  end

  private
  def provide_title
    @title = 'Users'
  end
end
