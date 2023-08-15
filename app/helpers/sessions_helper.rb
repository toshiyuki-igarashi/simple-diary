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

    :dairy_mode
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

# 複数の日記を取り扱う際に使う
#   def change_diary_form(new_form)
#     @current_diary_form = new_form
#     @current_form_id = new_form.id
#     @current_form = new_form.get_form
#   end

  def first_key_of_current_form
    current_form.keys[0]
  end

  def today
    Date.parse(Time.zone.now.to_s)
  end

  def picked_date
    Date.parse(session[:picked_date])
  end

  def go_to_picked_date
    if params[:commit] == "移動"
      session[:picked_date] = params[:diary][:date_of_diary]
      redirect_to :back
    end
  end

  def get_move_mode_string
    case (session[:move_mode])
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
    session[:picked_date] = date_of_diary
    session[:search_keyword] = ''
    session[:view_mode] = ''
    session[:move_mode] = ''
  end

  def download_file_clear
    if session[:download_file] != nil
      system("rm #{Rails.root.to_s}/public/data/#{session[:download_file]}")
    end
    session[:download_file] = nil
  end

  def session_clear
    session[:form_idx] = nil
    session[:user_id] = nil
    session[:picked_date] = nil
    session[:search_keyword] = nil
    session[:move_mode] = nil
    session[:view_mode] = nil
    download_file_clear
  end
end
