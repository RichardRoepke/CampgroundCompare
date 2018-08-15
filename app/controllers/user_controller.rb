class UserController < ApplicationController
  before_action :provide_title, :is_admin?
  #before_action

  def index
    @users = User.all.paginate(page: params[:page], per_page: 12)
  end

  def new
    @user = User.new()
    if params[:user]
      if @user.update(user_new)
        flash[:success] = 'User successfuly created.'
        redirect_to user_index_path
      else
        flash.now[:alert] = 'User could not be made.'
        @user.errors.full_messages.each do |error|
          flash.now[error.to_sym] = error unless error == 'Encrypted password can\'t be blank'
        end
      end
    end
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
    if params[:user].present?
      @user = User.find(params[:id])
      if @user.update(user_update)
        flash[:success] = 'User was updated successfully.'
        redirect_to user_index_path
      else
        flash[:alert] = 'User could not be updated.'
        @user.errors.full_messages.each do |error|
          flash[error.to_sym] = error
        end
        redirect_to edit_user_path(params[:id])
      end
    end
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

  def user_update
    if params[:user][:password].present?
      params.require(:user).permit(:admin, :password, :password_confirmation)
    else
      params.require(:user).permit(:admin)
    end
  end

  def user_new
    params.require(:user).permit(:email, :admin, :password, :password_confirmation)
  end
end
