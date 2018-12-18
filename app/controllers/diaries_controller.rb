class DiariesController < ApplicationController
  before_action :require_user_logged_in
  before_action :go_to_picked_date
  before_action :search

  include DiariesHelper
  include SessionsHelper

  def index
    @diary = Diary.find_by(user_id: current_user.id, date_of_diary: picked_date)
    if (session[:search_keyword])
      search_diary(session[:search_keyword])
    elsif @diary == nil
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
    session[:picked_date] = date_to_string(@diary[:date_of_diary])
    redirect_to diaries_url
  end

  def new
    @diary = Diary.find_by(user_id: current_user.id, date_of_diary: picked_date)
    unless @diary
      @diary = Diary.new
      @diary.date_of_diary = session[:picked_date]
    end
  end

  def create
    @diary = Diary.new(diary_params)
    old_diary = Diary.find_by(user_id: current_user.id, date_of_diary: picked_date)

    if params[:commit] == "投稿"
      if old_diary == nil
        @diary[:user_id] = current_user.id
        @diary[:date_of_diary] = picked_date
        if @diary.save
          flash[:success] = '日記が正常に保存されました'
          @date_of_diary = nil
          redirect_to @diary
        else
          flash.now[:danger] = '日記が保存されませんでした'
          render :new
        end
      else
        if old_diary.update(summary: @diary.summary, article: @diary.article)
          flash[:success] = '日記が正常に修正されました'
          redirect_to old_diary
        else
          flash.now[:danger] = '日記が修正されませんでした'
          render :new
        end
      end
    end
  end

  def edit
    @diary = Diary.find_by(user_id: current_user.id, date_of_diary: picked_date)
  end

  def update
    @diary = Diary.find_by(user_id: current_user.id, date_of_diary: picked_date)
    if @diary.update(summary: params[:diary][:summary], article: params[:diary][:article])
      flash[:success] = '日記が正常に修正されました'
      redirect_to @diary
    else
      flash.now[:danger] = '日記が修正されませんでした'
      render :edit
    end
  end

  def destroy
    @diary = Diary.find(params[:id])
    if @diary.user_id == current_user.id && @diary.date_of_diary == picked_date
      @diary.destroy
      flash[:success] = '日記が正常に削除されました'
    else
      flash[:danger] = '日記が削除されませんでした'
    end
    redirect_to diaries_url
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

  def search_diary(search_keyword)
    @diaries_all = Diary.where(user_id: current_user.id)
    @diaries = []
    @diaries_all.each do |diary|
      if (diary[:summary] && diary[:summary].include?(search_keyword)) || (diary[:article] && diary[:article].include?(search_keyword))
        @diaries.push(diary)
      end
    end
    @diaries = @diaries.sort { |a , b|
      if a[:date_of_diary] < b[:date_of_diary]
        1
      elsif a[:date_of_diary] == b[:date_of_diary]
        0
      else
        -1
      end
    }
  end

  # Strong Parameter
  def diary_params
    params.require(:diary).permit(:summary, :article)
  end
end
