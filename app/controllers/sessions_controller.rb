class SessionsController < ApplicationController
  def new
    session[:form_idx] = params[:id].to_i
  end

  def create
    email = params[:session][:email].downcase
    password = params[:session][:password]

    if password_check(email, password)
      logged_in_session
      flash[:success] = 'ログインに成功しました。'
      if memo_mode?
        redirect_to show_memo_url(view_mode: select_category, form_idx: session[:form_idx])
      else
        redirect_to new_diary_url(form_idx: session[:form_idx])
      end
    else
      flash.now[:danger] = 'ログインに失敗しました。'
      render 'new'
    end
  end

  def destroy
    if logged_in?
      session_clear
      flash[:success] = 'ログアウトしました。'
    end
    redirect_to root_url
  end
end
