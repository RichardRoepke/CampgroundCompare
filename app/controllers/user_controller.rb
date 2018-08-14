class UserController < ApplicationController
  before_action :provide_title

  def index
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
