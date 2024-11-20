# 日付表示をデフォールトの'YYYY-MM-DD HH:MM:SS'から、'YYYY/MM/DD (曜日)'に置き換える
DAY_OF_WEEK = ['日','月','火','水','木','金','土']

module SessionsHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
  end

  def memo_mode?
    current_diary_form.get_form.key?('カテゴリ')
  end

  def run_mode
    return :logged_out unless logged_in?
    return :memo_mode if memo_mode?

    :diary_mode
  end

  def get_category_list
    @category_list = []
    @diaries = []
    @diaries = Diary.get_memos(current_form_id) if memo_mode?

    @diaries.each do |memo|
      @category_list << memo.get('カテゴリ') unless @category_list.include?(memo.get('カテゴリ'))
    end
  end

  def concat_sym(sym, num)
    num = (num.class == Integer ? num.to_s : '')
    "#{sym.to_s}#{num}".to_sym
  end

  def session_sym(sym)
    concat_sym(sym, current_form_idx)
  end

  def select_category
    return session[session_sym(:category)] if session[session_sym(:category)] && session[session_sym(:category)] != ''

    'show_all'
  end

  def user_diary_forms
    @user_diary_forms ||= DiaryForm.where(user_id: current_user.id)
  end

  def current_form_idx
    session[:form_idx] ? session[:form_idx].to_i : 0
  end

  def current_diary_form
    @current_diary_form ||= DiaryForm.where(user_id: current_user.id)[current_form_idx]
    @current_diary_form ||= DiaryForm.where(user_id: current_user.id)[0]
  end

  def current_form_id
    @current_form_id ||= current_diary_form.id
  end

  def current_form
    @current_form ||= current_diary_form.get_form
  end

  def current_packed_form
    if (!@current_packed_form)
      @current_packed_form = {}
      keys = current_form.keys
      number_item = nil
      0.upto(keys.length-1) do |i|
        if current_form[keys[i]]["タイプ"] == "数字"
          if number_item
            @current_packed_form[keys[i]] = { number_item => current_form[number_item], keys[i] => current_form[keys[i]] }
            number_item = nil
          else
            number_item = keys[i]
          end
        else
          if (number_item)
            @current_packed_form[number_item] = { number_item => current_form[number_item] }
            number_item = nil
          end
          @current_packed_form[keys[i]] = current_form[keys[i]]
        end
      end
    end
    @current_packed_form
  end

  def first_key_of_current_form
    current_form.keys[0]
  end

  def second_key_of_current_form
    current_form.keys[1]
  end

  def today
    Date.parse(Time.zone.now.to_s)
  end

  def invalid_date?(date)
    Date::_parse(date)[:year].nil?
  end

  def picked_date
    session[session_sym(:picked_date)] = Date::today.to_s if invalid_date?(session[session_sym(:picked_date)])

    Date::parse(session[session_sym(:picked_date)])
  end

  def go_to_picked_date
    if params[:commit] == "移動"
      session[session_sym(:picked_date)] = params[:diary][:date_of_diary]
      redirect_to :back
    end
  end

  def get_move_mode_string
    case (session[session_sym(:move_mode)])
    when 'day'
      '日'
    when 'week'
      '週'
    when 'month'
      '月'
    end
  end

  def date_to_string(date)
    "#{date.strftime('%Y/%m/%d')} (#{DAY_OF_WEEK[date.wday]})"
  end

  def day_of_week(date)
    "(#{DAY_OF_WEEK[Date.parse(date).wday]}曜日)"
  end

  def kind_of_day(date)
    case (Date.parse(date))
    when today - 1
      '[昨日] '
    when today
      '[本日] '
    when today + 1
      '[明日] '
    end
  end

  def password_check(email, password)
    @user = User.find_by(email: email)
    if @user && @user.authenticate(password)
      # パスワードチェック成功
      return true
    else
      # パスワードチェック失敗
      return false
    end
  end

  def logged_in_session
    session[:user_id] = @user.id
    if (Time.zone.now.hour >= 18)
      date_of_diary = Time.zone.now.to_s[0..9]
    else
      date_of_diary = Time.zone.yesterday.to_s[0..9]
    end
    session[session_sym(:picked_date)] = date_of_diary
    session[session_sym(:search_keyword)] = ''
    session[session_sym(:view_mode)] = ''
    session[session_sym(:move_mode)] = ''
  end

  def session_status_clear(form_idx)
    session[concat_sym(:picked_date, form_idx)] = nil
    session[concat_sym(:search_keyword, form_idx)] = nil
    session[concat_sym(:move_mode, form_idx)] = nil
    session[concat_sym(:view_mode, form_idx)] = nil
    session[concat_sym(:category, form_idx)] = nil
    session[concat_sym(:memo_id, form_idx)] = nil
  end

  def download_file_clear(form_idx)
    download_sym = concat_sym(:download_file, form_idx)
    if session[session_sym(:download_file)] != nil
      system("rm #{Rails.root.to_s}/public/data/#{session[session_sym(:download_file)]}")
    end
    session[session_sym(:download_file)] = nil
  end

  def session_clear
    (0..user_diary_forms.size-1).each do |form_idx|
      session_status_clear(form_idx)
      download_file_clear(form_idx)
    end
    session[:user_id] = nil
  end
end
