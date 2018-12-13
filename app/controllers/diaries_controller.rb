
# 日付表示をデフォールトの'YYYY-MM-DD HH:MM:SS'から、'YYYY/MM/DD (曜日)'に置き換える
DAY_OF_WEEK = ['日','月','火','水','木','金','土']
class Date
  def to_s
    "#{self.strftime('%Y/%m/%d')} (#{DAY_OF_WEEK[self.wday]})"
  end
end

class DiariesController < ApplicationController
  before_action :require_user_logged_in

  def index
    redirect_to root_url
  end

  def show
  end

  def new
    @diary = Diary.new
    @diary.date_of_diary = Date.today
  end

  def create
    @diary = Diary.new(diary_params)
    @diary[:user_id] = current_user.id
    if params[:day_before]
      @diary.date_of_diary = @diary.date_of_diary.prev_day
    elsif params[:month_before]
      @diary.date_of_diary = @diary.date_of_diary.prev_month
    elsif params[:month_after]
      @diary.date_of_diary = @diary.date_of_diary.next_month
    elsif params[:day_after]
      @diary.date_of_diary = @diary.date_of_diary.next_day
    else
      if @diary.save
        flash[:success] = '日記が正常に保存されました'
        @date_of_diary = nil
        redirect_to @diary
      else
        flash.now[:danger] = '日記が保存されませんでした'
      end
    end
    render :new
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  # Strong Parameter
  def diary_params
    params.require(:diary).permit(:date_of_diary, :summary, :article)
  end
end
