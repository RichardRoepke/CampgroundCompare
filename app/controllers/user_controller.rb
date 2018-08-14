class UserController < ApplicationController
  before_action :provide_title, :is_admin?
  #before_action

  def index
    @users = User.all.paginate(page: params[:page], per_page: 15)
  end

  def new
  end

  def edit

  end

  def show
    @user = User.find(params[:id])
  end

  def search

  end

  def update

  end

  def delete

  end

  private
  def provide_title
    @title = 'Users'
  end
end
