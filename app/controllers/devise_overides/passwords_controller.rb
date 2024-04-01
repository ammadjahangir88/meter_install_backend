class DeviseOverides::PasswordsController < Devise::PasswordsController
  def edit
    @user = User.with_reset_password_token(params[:reset_password_token])
    redirect_to new_user_session_url, alert: 'Link has expired.' unless @user.present?
    super
  end
  def update
    @user = User.with_reset_password_token(params[:user][:reset_password_token])
    return redirect_to new_user_session_url, alert: 'Account not active' unless @user.present? && @user.admin?
    super
  end
end