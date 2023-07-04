class DiariesController < ApplicationController
  before_action :require_user_logged_in
  before_action :go_to_picked_date
  before_action :search, except: [:show_search]
  before_action :prepare_picked_diary, only: [:create, :edit]
  before_action :prepare_move_date, only: [:show_diary, :new, :edit]
  before_action :save_view_mode, only: [:new, :create, :edit]

  def show_diary
    session[:view_mode] = params[:view_mode]

    if (params[:commit] == "検索")
      session[:search_keyword] = params[:search]
      session[:view_mode] = 'show_search'
    elsif (params[:commit] == "絞込検索")
      session[:search_keyword] += ' ' + params[:search]
      session[:view_mode] = 'show_search'
    end

    case (session[:view_mode])
    when 'show_day'
      prepare_picked_diary
    when 'show_week'
      @diaries = Diary.get_diaries(current_form_id, picked_date, 6)
      make_graph
      session[:move_mode] = 'week'
    when 'show_month'
      @diaries = Diary.get_diaries(current_form_id, picked_date, 31)
      make_graph
      session[:move_mode] = 'month'
    when 'show_year'
      @diaries = Diary.get_diaries_of_month(current_form_id, picked_date, 11)
      make_graph
    when 'show_3years'
      @diaries = Diary.get_diaries_of_years(current_form_id, picked_date, 2)
    when 'show_5years'
      @diaries = Diary.get_diaries_of_years(current_form_id, picked_date, 4)
    when 'show_10years'
      @diaries = Diary.get_diaries_of_years(current_form_id, picked_date, 9)
    when 'show_search'
      @diaries = Diary.search_diary(session[:search_keyword], current_form_id)
    else
      session[:view_mode] = 'show_day'
      prepare_picked_diary
    end
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
      redirect_to show_diary_url(view_mode: "show_day")
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
      @diary.images.attach(params[:images]) if params[:images]
      if @diary.save
        flash[:success] = '日記が正常に保存されました'
        redirect_to show_diary_url(view_mode: "show_day")
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
      @diary.delete_images
      @diary.destroy
      flash[:success] = '日記が正常に削除されました'
    else
      flash[:danger] = '日記が削除されませんでした'
    end
    redirect_to show_diary_url(view_mode: "show_day")
  end

  def move_date
    case(params[:move_mode])
    when 'prev_day'
      session[:picked_date] = picked_date.prev_day.to_s
    when 'next_day'
      session[:picked_date] = picked_date.next_day.to_s
    when 'prev_week'
      session[:picked_date] = (picked_date - 7).to_s
    when 'next_week'
      session[:picked_date] = (picked_date + 7).to_s
    when 'prev_month'
      session[:picked_date] = picked_date.prev_month.to_s
    when 'next_month'
      session[:picked_date] = picked_date.next_month.to_s
    when 'picked_date'
      session[:picked_date] = params[:picked_date]
    end
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
    session[:move_mode] = 'day'
  end

  def redirect_to_back
    case (session[:view_mode])
    when 'show_day', 'show_week', 'show_month', 'show_year', 'show_3years', 'show_5years', 'show_10years'
      redirect_to show_diary_url(view_mode: session[:view_mode])
    when 'new'
      redirect_to new_diary_url
    when 'edit'
      prepare_picked_diary
      if (@diary.id)
        redirect_to edit_diary_url(@diary)
      else
        redirect_to new_diary_url
      end
    else
      redirect_to root_url
    end
  end

  def save_view_mode
    session[:view_mode] = action_name
  end

  def update_diary(diary, articles)
    if diary.update(article: make_article(articles))
      diary.images.attach(params[:images]) if params[:images]
      if params[:remove_images]
        params[:remove_images].each do |image_id|
          diary.images.find(image_id).purge
        end
      end
      flash[:success] = '日記が正常に修正されました'
      redirect_to show_diary_url(view_mode: "show_day")
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

  def make_graph_hash
    @graph = {}
    current_form.each do |key, value|
      if (value['タイプ'] == '数字')
        @graph[key] = { name: key, unit: value['単位'], data: {} }
      end
    end
  end

  def get_graph_data
    @diaries.each do |diary|
      @graph.each do |key, value|
        value[:data][diary[:date_of_diary]] = diary.get(key)
      end
    end
  end


  def refine_graph_data
    @graph_data = {}
    @graph.each do |key, value|
      @graph_data[value[:unit]] ||= []
      @graph_data[value[:unit]].push(value)
      value.delete(:unit)
    end
  end

  def make_graph
    make_graph_hash
    get_graph_data
    refine_graph_data
  end
end
