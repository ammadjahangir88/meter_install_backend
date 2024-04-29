class V1::UsersController < ApplicationController
    before_action :set_user, only: [:show, :update, :destroy]
    def index
        @users = User.all
        render json: @users, only: [:id,:username, :email, :role]
    end
    def update
        if @user.update(user_params)
          render json: { message: 'User updated successfully', user: @user }, status: :ok
        else
          render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
        end
    end
      def show
        render json: @user, only: [:id, :username, :email, :role], status: :ok
      end
    def destroy
        if @user.destroy
          render json: { message: 'User deleted successfully' }, status: :ok
        else
          render json: { error: 'Failed to delete user' }, status: :unprocessable_entity
        end
    end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :role)
  end
  def authenticate_request!
    header = request.headers['Authorization']
    if header && header.split(' ').first == 'JWT'
      token = header.split(' ').last
      begin
        decoded_token = JWT.decode(token, 'your_secret_key', true, algorithm: 'HS256')
        @current_user = User.find(decoded_token.first['user_id'])
      rescue JWT::DecodeError => e
        render json: { message: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { message: 'Authorization header missing' }, status: :unauthorized
    end
  end
end    