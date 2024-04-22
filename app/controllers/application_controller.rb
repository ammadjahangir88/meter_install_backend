class ApplicationController < ActionController::API
  include ActionController::MimeResponds
    before_action :authenticate_request!

  private

  def authenticate_request!
    unless devise_controller? || excluded_routes.include?(request.path)
      header = request.headers['Authorization']
      if header && header.split(' ').first == 'Bearer'
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

  def excluded_routes
    [
      new_user_session_path,
      user_session_path,
      new_user_registration_path,
      user_registration_path
    ]
  end
end
