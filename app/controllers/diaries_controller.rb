class DiariesController < ApplicationController
  before_action :require_user_logged_in
  before_action :go_to_picked_date
  before_action :search, except: [:show_search]
  before_action :prepare_picked_diary, only: [:show_day, :show_week, :show_month, :show_3years, :show_5years, :show_10years, :create, :edit]
  before_action :prepare_move_date, only: [:show_day, :show_3years, :show_5years, :show_10years, :new, :edit]
  before_action :save_view_mode, only: [:show_day, :show_week, :show_month, :show_3years, :show_5years, :show_10years, :new, :create, :edit]

  def show_day
  end

  def show_week
    @show_mode = '週'
    @set_prev_date_path = prev_week_path
    @set_next_date_path = next_week_path
    @diaries = Diary.get_diaries(current_form_id, picked_date, 6)
    render '_show_several_diaries'
  end

  def show_month
    @show_mode = '月'
    @set_prev_date_path = prev_month_path
    @set_next_date_path = next_month_path
    @diaries = Diary.get_diaries(current_form_id, picked_date, 31)
  end

  def show_3years
    @diaries = Diary.get_diaries_of_years(current_form_id, picked_date, 2)
    render '_show_several_diaries'
  end

  def show_5years
    @diaries = Diary.get_diaries_of_years(current_form_id, picked_date, 4)
    render '_show_several_diaries'
  end

  def show_10years
    @diaries = Diary.get_diaries_of_years(current_form_id, picked_date, 9)
    render '_show_several_diaries'
  end

  def show_search
    if (params[:commit] == "検索")
      session[:search_keyword] = params[:search]
    elsif (params[:commit] == "絞込検索")
      session[:search_keyword] += ' ' + params[:search]
    end
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
    if params[:date_of_diary]
      session[:picked_date] = params[:date_of_diary]
    end
    prepare_picked_diary
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
    redirect_to_back
  end

  def next_day
    session[:picked_date] = picked_date.next_day
    redirect_to_back
  end

  def prev_week
    session[:picked_date] = picked_date - 7
    redirect_to_back
  end

  def next_week
    session[:picked_date] = picked_date + 7
    redirect_to_back
  end

  def prev_month
    session[:picked_date] = picked_date.prev_month
    redirect_to_back
  end

  def next_month
    session[:picked_date] = picked_date.next_month
    redirect_to_back
  end

  def select_date
    session[:picked_date] = params[:picked_date]
    redirect_to_back
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

  def redirect_to_back
    case (session[:view_mode])
    when 'show_day'
      redirect_to show_day_url
    when 'show_week'
      redirect_to show_week_url
    when 'show_month'
      redirect_to show_month_url
    when 'show_3years'
      redirect_to show_3years_url
    when 'show_5years'
      redirect_to show_5years_url
    when 'show_10years'
      redirect_to show_10years_url
    when 'new'
      redirect_to new_diary_url
    when 'edit'
      redirect_to edit_diary_url
    else
      redirect_to root_url
    end
  end

  def save_view_mode
    session[:view_mode] = action_name
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
