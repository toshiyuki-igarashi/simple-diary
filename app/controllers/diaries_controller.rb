class DiariesController < ApplicationController
  before_action :require_user_logged_in

  def index
    redirect_to root_url
  end

  def show
  end

  def new
    @diary = Diary.new
    @diary.date_of_diary = Time.now
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
