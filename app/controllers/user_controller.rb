class UserController < ApplicationController
  before_action :provide_title, :is_admin?

  def index
    @users = User.all.paginate(page: params[:page], per_page: 15)
  end

  def new
  end

  def edit

  end

  def show

  end

  def update

  end

  def delete

  end

  def provide_title
    @title = 'Users'
  end
end
