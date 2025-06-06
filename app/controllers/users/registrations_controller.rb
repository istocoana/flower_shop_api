class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    user = User.new(sign_up_params)

    if user.save
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first

      render json: {
        message: "Account created successfully",
        user: user,
        token: token
      }, status: :created
    else
      render json: {
        message: "Account could not be created",
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params[:user][:role] = "customer"
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
