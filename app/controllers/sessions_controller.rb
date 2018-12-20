class SessionsController < ApplicationController
  def new
  end

  def create
    email = params[:session][:email].downcase
    password = params[:session][:password]

    if password_check(email, password)
      logged_in_session
      flash[:success] = 'ログインに成功しました。'
      redirect_to new_diary_url
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
end
