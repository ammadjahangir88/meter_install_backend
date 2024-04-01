class  DeviseOverides::UsersController < Devise::RegistrationsController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    binding.pry

    @user = User.new(user_params)
      if @user.save
        render json: { user: @user }
      else
        respond_with_error "Invalid data", :not_found
      end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :role )
  end
end
