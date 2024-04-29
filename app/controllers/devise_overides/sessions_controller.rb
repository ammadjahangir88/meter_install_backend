class DeviseOverides::SessionsController < Devise::SessionsController
  respond_to :json

  def create
    user = User.find_by(email: params[:user]["email"])

    if user && user.valid_password?(params[:user]["password"])
      sign_in user, store: false
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)

      # Generate token with expiration time
      token = JWT.encode({ user_id: user.id, exp: 1.days.from_now.to_i }, 'your_secret_key', 'HS256')

      render json: { success: true, message: "Login successful", user: user, token: token }, status: :ok
    else
      render json: { success: false, message: "Invalid email or password" }, status: :unauthorized
    end
  end
end
