class DiariesController < ApplicationController
  before_action :require_user_logged_in
  before_action :go_to_picked_date
  before_action :search
  before_action :prepare_picked_diary, only: [:index, :new, :edit]

  def index
    if (session[:search_keyword])
      @diaries = Diary.search_diary(session[:search_keyword], current_user)
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
    else
      session[:picked_date] = @diary[:date_of_diary]
      redirect_to diaries_url
    end
  end

  def new
  end

  def create
    if params[:commit] == "保存"
      if prepare_picked_diary == nil
        @diary[:summary] = params[:diary][:summary]
        @diary[:article] = params[:diary][:article]
        if @diary.save
          flash[:success] = '日記が正常に保存されました'
          redirect_to @diary
        else
          flash.now[:danger] = '日記が保存されませんでした'
          render :new
        end
      else
        update_diary(old_diary, @diary.summary, @diary.article)
      end
    else
      flash.now[:danger] = '日記がプログラムエラーで作成できませんでした'
      prepare_picked_diary
      render :new
    end
  end

  def edit
  end

  def update
    @diary = Diary.find_by(user_id: current_user.id, date_of_diary: picked_date)
    update_diary(@diary, params[:diary][:summary], params[:diary][:article])
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
    session[:picked_date] = picked_date.prev_day
    redirect_to :back
  end

  def next_day
    session[:picked_date] = picked_date.next_day
    redirect_to :back
  end

  def select_date
    session[:picked_date] = params[:picked_date]
    redirect_to :back
  end

  private

  def prepare_picked_diary
    @diary = Diary.find_by(user_id: current_user.id, date_of_diary: picked_date)
    if @diary == nil
      @diary = Diary.new(user_id: current_user.id, date_of_diary: picked_date)
      nil
    end
  end

  def update_diary(diary, summary, article)
    if diary.update(summary: summary, article: article)
      flash[:success] = '日記が正常に修正されました'
      redirect_to diary
    else
      flash.now[:danger] = '日記が修正されませんでした'
      render :edit
    end
  end
end
