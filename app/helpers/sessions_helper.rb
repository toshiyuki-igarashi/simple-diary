# 日付表示をデフォールトの'YYYY-MM-DD HH:MM:SS'から、'YYYY/MM/DD (曜日)'に置き換える
DAY_OF_WEEK = ['日','月','火','水','木','金','土']

module SessionsHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
  end

  def current_form
    @current_form ||= DiaryForm.find_by(user_id: current_user.id).id
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

  def date_to_string(date)
    "#{date.strftime('%Y/%m/%d')} (#{DAY_OF_WEEK[date.wday]})"
  end

  def day_of_week(date)
    "(#{DAY_OF_WEEK[Date.parse(date).wday]}曜日)"
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
  end

  def session_clear
    session[:user_id] = nil
    session[:picked_date] = nil
    session[:search_keyword] = nil
  end
end
