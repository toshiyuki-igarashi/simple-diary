# 日付表示をデフォールトの'YYYY-MM-DD HH:MM:SS'から、'YYYY/MM/DD (曜日)'に置き換える
DAY_OF_WEEK = ['日','月','火','水','木','金','土']

module SessionsHelper
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
  end

  def picked_date
    Date.parse(session[:picked_date])
  end

  def date_to_string(date)
    "#{date.strftime('%Y/%m/%d')} (#{DAY_OF_WEEK[date.wday]})"
  end

  def go_to_picked_date
    if params[:commit] == "移動"
      session[:picked_date] = params[:diary][:date_of_diary]
      redirect_to :back
    end
  end
end
