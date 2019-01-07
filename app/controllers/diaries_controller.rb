class DiariesController < ApplicationController
  before_action :require_user_logged_in
  before_action :go_to_picked_date
  before_action :search
  before_action :prepare_picked_diary, only: [:show_day, :show_week, :show_month, :show_3years, :show_5years, :new, :create, :edit]
  before_action :prepare_move_date, only: [:show_day, :show_3years, :show_5years, :new, :edit]

  def show_day
  end

  def show_week
    @show_mode = '週'
    @set_prev_date_path = prev_week_path
    @set_next_date_path = next_week_path
    @diaries = Diary.get_diaries(current_form_id, picked_date, 6)
  end

  def show_month
    @show_mode = '月'
    @set_prev_date_path = prev_month_path
    @set_next_date_path = next_month_path
    @diaries = Diary.get_diaries(current_form_id, picked_date, 31)
  end

  def show_3years
    @diaries = Diary.get_diaries_of_years(current_form_id, picked_date, 2)
  end

  def show_5years
    @diaries = Diary.get_diaries_of_years(current_form_id, picked_date, 4)
  end

  def show_search
    @diaries = Diary.search_diary(session[:search_keyword], current_form_id)
  end

  def show
    @diary = Diary.find_by(id: params[:id])
    if (@diary == nil)
      flash[:danger] = '日記は存在しません'
      redirect_to root_url
    elsif (!my_diary?(@diary))
      flash[:danger] = '他人の日記は表示できません'
      redirect_to root_url
    else
      session[:picked_date] = @diary[:date_of_diary]
      redirect_to show_day_url
    end
  end

  def new
  end

  def create
    if @diary.id == nil
      @diary[:article] = make_article(params)
      if @diary.save
        flash[:success] = '日記が正常に保存されました'
        redirect_to show_day_url
      else
        flash.now[:danger] = '日記が保存されませんでした'
        render :new
      end
    else
      update_diary(@diary, params)
    end
  end

  def edit
  end

  def update
    @diary = Diary.find_by(form_id: current_form_id, date_of_diary: picked_date)
    update_diary(@diary, params)
  end

  def destroy
    @diary = Diary.find(params[:id])
    if @diary.get_user_id == current_user.id && @diary.date_of_diary == picked_date
      @diary.destroy
      flash[:success] = '日記が正常に削除されました'
    else
      flash[:danger] = '日記が削除されませんでした'
    end
    redirect_to show_day_url
  end

  def prev_day
    session[:picked_date] = picked_date.prev_day
    redirect_to :back
  end

  def next_day
    session[:picked_date] = picked_date.next_day
    redirect_to :back
  end

  def prev_week
    session[:picked_date] = picked_date - 7
    redirect_to :back
  end

  def next_week
    session[:picked_date] = picked_date + 7
    redirect_to :back
  end

  def prev_month
    session[:picked_date] = picked_date.prev_month
    redirect_to :back
  end

  def next_month
    session[:picked_date] = picked_date.next_month
    redirect_to :back
  end

  def select_date
    session[:picked_date] = params[:picked_date]
    redirect_to :back
  end

  private

  def my_diary?(diary)
    diary.get_user_id == current_user.id
  end

  def prepare_picked_diary
    @diary = Diary.prepare_diary(current_form_id, picked_date)
  end

  def prepare_move_date
    @show_mode = '日'
    @set_prev_date_path = prev_day_path
    @set_next_date_path = next_day_path
  end

  def update_diary(diary, articles)
    if diary.update(article: make_article(articles))
      flash[:success] = '日記が正常に修正されました'
      redirect_to show_day_url
    else
      flash.now[:danger] = '日記が修正されませんでした'
      render :edit
    end
  end

  def make_article(article_input)
    article = {}
    current_form.each do |key, value|
      article[key] = article_input[key]
    end

    JSON.generate(article).to_s
  end
end
