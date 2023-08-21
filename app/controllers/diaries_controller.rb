module DiaryMode
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
      make_graph(current_form_id)
      session[:move_mode] = 'week'
    when 'show_month'
      @diaries = Diary.get_diaries(current_form_id, picked_date, 31)
      make_graph(current_form_id)
      session[:move_mode] = 'month'
    when 'show_year'
      @diaries = Diary.get_diaries_of_month(current_form_id, picked_date, 11)
      make_graph(current_form_id, 2)
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
end

module MemoMode
  def select_memo(category)
    get_category_list
    selected = []
    @diaries.each do |memo|
      selected << memo if memo.get('カテゴリ') == category
    end
    @diaries = selected
  end

  def show_memo
    session[:view_mode] = params[:view_mode]
    session[:memo_id] = params[:memo_id]

    if (params[:commit] == "検索")
      session[:search_keyword] = params[:search]
      session[:view_mode] = 'show_search'
    elsif (params[:commit] == "絞込検索")
      session[:search_keyword] += ' ' + params[:search]
      session[:view_mode] = 'show_search'
    end

    case session[:view_mode]
    when 'show_memo'
      prepare_picked_diary
    when 'show_search'
      @diaries = Diary.search_diary(session[:search_keyword], current_form_id)
    when 'show_all', '全て'
      get_category_list
      session[:category] = '全て'
      session[:view_mode] = 'show_all'
    else
      select_memo(session[:view_mode])
      session[:category] = session[:view_mode]
      session[:view_mode] = 'show_all'
    end
  end
end

class DiariesController < ApplicationController
  include DiaryMode, MemoMode

  before_action :require_user_logged_in
  before_action :go_to_picked_date
  before_action :search, except: [:show_search]
  before_action :prepare_picked_diary, only: [:create, :edit]
  before_action :prepare_move_date, only: [:show_diary, :new, :edit]
  before_action :save_view_mode, only: [:new, :create, :edit]

  def default_show_url
    prepare_picked_diary
    return show_memo_url(view_mode: "show_memo", memo_id: @diary.id) if memo_mode?

    show_diary_url(view_mode: "show_day")
  end

  def show_after_move_url
    prepare_picked_diary
    return show_memo_url(view_mode: session[:category], memo_id: @diary.id) if memo_mode?

    show_diary_url(view_mode: "show_day")
  end

  def show
    @diary = Diary.find_by(id: params[:id])
    session[:memo_id] = params[:id]
    if (@diary == nil)
      flash[:danger] = '日記は存在しません'
      redirect_to root_url
    elsif (!my_diary?(@diary))
      flash[:danger] = '他人の日記は表示できません'
      redirect_to root_url
    else
      session[:picked_date] = @diary[:date_of_diary].to_s
      redirect_to default_show_url
    end
  end

  def new
    if memo_mode?
      @diary = Diary.new(form_id: current_form_id, date_of_diary: picked_date)
      session[:memo_id] = @diary.id
    else
      if params[:date_of_diary]
        session[:picked_date] = params[:date_of_diary]
      end
      prepare_picked_diary
    end
  end

  def create
    session[:picked_date] = params[:date_input] if params[:date_input]
    @diary[:date_of_diary] = picked_date if memo_mode?
    if @diary.id == nil
      @diary[:article] = make_article(params)
      @diary.images.attach(params[:images]) if params[:images]
      if @diary.save
        flash[:success] = '日記が正常に保存されました'
        session[:memo_id] = @diary.id
        redirect_to default_show_url
      else
        flash.now[:danger] = '日記が保存されませんでした'
        render :new
      end
    else
      update_diary(@diary, params)
    end
  end

  def edit
    session[:memo_id] = params[:id]
    if memo_mode?
      @diary = Diary.find_by(id: session[:memo_id])
      session[:picked_date] = @diary[:date_of_diary].to_s
    end
  end

  def update
    @diary = memo_mode? ? Diary.find_by(id: session[:memo_id]) : Diary.find_by(form_id: current_form_id, date_of_diary: picked_date)
    update_diary(@diary, params)
  end

  def valid_destroy?
    return false unless @diary.get_user_id == current_user.id
    return true if @diary.date_of_diary == picked_date || memo_mode?

    false
  end

  def destroy
    @diary = Diary.find(params[:id])
    if valid_destroy?
      @diary.delete_images
      @diary.destroy
      flash[:success] = '日記が正常に削除されました'
    else
      flash[:danger] = '日記が削除されませんでした'
    end
    redirect_to show_after_move_url
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

  def move_diary
    session[:form_idx] = params[:id]
    redirect_to show_after_move_url
  end

  private

  def my_diary?(diary)
    diary.get_user_id == current_user.id && diary.form_id == current_form_id
  end

  def prepare_picked_diary
    if memo_mode?
      @diary = Diary.find_by(id: session[:memo_id])
      @diary = Diary.new(form_id: current_form_id, date_of_diary: Date.today.to_s) if @diary == nil || !my_diary?(@diary)
      session[:picked_date] = @diary[:date_of_diary].to_s
    else
      @diary = Diary.prepare_diary(current_form_id, picked_date)
    end
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
      redirect_to default_show_url
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

  def diaries_of_period(form_id, period, center_date)
    diaries = []
    first_date = center_date + period
    0.upto(period * 2) do |i|
      diaries << Diary.prepare_diary(form_id, first_date - i)
    end
    diaries
  end

  def average_value(diaries, key)
    idx = 0
    sum = 0.0
    diaries.each do |diary|
      if !diary.get(key).nil? && /[\d.]+/ =~ diary.get(key)
        idx += 1
        sum += Regexp.last_match[0].to_f
      end
    end
    return nil if idx.zero?

    (sum / idx).to_s
  end

  def get_graph_data(form_id, average_period)
    @diaries.each do |diary|
      average_diaries = diaries_of_period(form_id, average_period, diary[:date_of_diary])
      @graph.each do |key, value|
        value[:data][diary[:date_of_diary]] = average_value(average_diaries, key)
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

  def make_graph(form_id, average_period = 0)
    make_graph_hash
    get_graph_data(form_id, average_period)
    refine_graph_data
  end
end
