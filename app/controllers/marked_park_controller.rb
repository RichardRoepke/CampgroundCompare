class MarkedParkController < ApplicationController
  before_action :provide_title

  def index
    @parks = MarkedPark.page(params[:page]).per(12)
  end

  private
  def provide_title
    @title = 'Parks'
  end
end