class DiariesController < ApplicationController
  before_action :require_user_logged_in

  include SessionsHelper

  def index
    @diary = Diary.find_by(user_id: current_user.id, date_of_diary: picked_date)
    if @diary == nil
      @diary = Diary.new(user_id: current_user.id, date_of_diary: picked_date)
    end
  end

  def show
    @diary = Diary.find_by(id: params[:id])
    if (@diary == nil)
      flash[:danger] = '日記は存在しません'
      redirect_to root_url
    elsif (@diary.user_id != current_user.id)
      flash[:danger] = '他人の日記は表示できません'
      redirect_to root_url
    end
  end

  def new
    @diary = Diary.new
    @diary.date_of_diary = session[:picked_date]
  end

  def create
    @diary = Diary.new(diary_params)
    old_diary = Diary.find_by(user_id: current_user.id, date_of_diary: @diary.date_of_diary)

    if old_diary == nil
      @diary[:user_id] = current_user.id
      if @diary.save
        flash[:success] = '日記が正常に保存されました'
        @date_of_diary = nil
        redirect_to @diary
      else
        flash.now[:danger] = '日記が保存されませんでした'
        render :new
      end
    else
      old_diary.update(summary: @diary.summary, article: @diary.article)
      redirect_to old_diary
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def prev_day
    session[:picked_date] = date_to_string(picked_date.prev_day)
    redirect_to :back
  end

  def prev_month
    session[:picked_date] = date_to_string(picked_date.prev_month)
    redirect_to :back
  end

  def next_day
    session[:picked_date] = date_to_string(picked_date.next_day)
    redirect_to :back
  end

  def next_month
    session[:picked_date] = date_to_string(picked_date.next_month)
    redirect_to :back
  end

  private

  # Strong Parameter
  def diary_params
    params.require(:diary).permit(:date_of_diary, :summary, :article)
  end
end
