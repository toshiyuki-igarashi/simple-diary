class SessionsController < ApplicationController
  def new
    session[:form_idx] = params[:id]
  end

  def create
    email = params[:session][:email].downcase
    password = params[:session][:password]

    if password_check(email, password)
      logged_in_session
      flash[:success] = 'ログインに成功しました。'
      if memo_mode?
        redirect_to show_memo_url(view_mode: 'show_all')
      else
        redirect_to new_diary_url
      end
    else
      flash.now[:danger] = 'ログインに失敗しました。'
      render 'new'
    end
  end

  def destroy
    session_clear
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
end
