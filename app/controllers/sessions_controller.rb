class SessionsController < ApplicationController
  include SessionsHelper

  def new
  end

  def create
    email = params[:session][:email].downcase
    password = params[:session][:password]

    if login(email, password)
      flash[:success] = 'ログインに成功しました。'
      #redirect_to @user
      redirect_to root_url    # user controllerをインプリするまで、仮にrootを表示する
    else
      flash.now[:danger] = 'ログインに失敗しました。'
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    session[:picked_date] = nil
    session[:search_keyword] = nil
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end

  private

  def login(email, password)
    @user = User.find_by(email: email)
    if @user && @user.authenticate(password)
      # ログイン成功
      session[:user_id] = @user.id
      if (Time.zone.now.hour >= 18)
        date_of_diary = Date.today
      else
        date_of_diary = Date.today.prev_day
      end
      session[:picked_date] = date_to_string(date_of_diary)
      return true
    else
      # ログイン失敗
      return false
    end
  end
end
