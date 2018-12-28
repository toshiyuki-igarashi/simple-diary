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
      if (!DiaryForm.new(user_id: @user.id, title: '日記帳', form: '{"トピック": 50,"本文": 0}').save)
        puts "**** Alert **** diary_form hasn't saved for user (user_id: #{@user.id}) [CODE 100]"
        flash[:success] = 'プログラムエラーでユーザに失敗しました。[CODE 100]'
      end
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
    current_user.delete_all

    session_clear
    flash[:success] = 'ユーザの登録を削除しました。またのご利用をお待ちしております。'
    redirect_to root_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
