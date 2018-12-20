class UsersController < ApplicationController
  before_action :require_user_logged_in, only: [:show, :edit, :update, :destroy]

  def show
    @user = current_user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = 'ユーザを登録しました。'
      logged_in_session
      redirect_to root_url
    else
      flash.now[:danger] = 'ユーザの登録に失敗しました。'
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
    if @user.id != current_user.id
      redirect_to root_url
    end
  end

  def update
    email = params[:user][:email].downcase
    password = params[:user][:password]

    if password_check(email, password) && @user.id == current_user.id
      if (@user.update(user_params))
        flash[:success] = 'ユーザ情報の修正に成功しました。'
        redirect_to diaries_url
      else
        flash.now[:danger] = 'ユーザ情報の修正に失敗しました。'
        render :edit
      end
    else
      flash[:danger] = 'ユーザ情報の修正に失敗しました。'
      redirect_to diaries_url
    end
  end

  def destroy
    session[:user_id] = nil
    session[:picked_date] = nil
    session[:search_keyword] = nil
    flash[:success] = 'ユーザの登録を削除しました。またのご利用をお待ちしております。'
    redirect_to root_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
