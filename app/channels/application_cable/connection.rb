module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]
      decoded_token = Warden::JWTAuth::TokenDecoder.new.call(token)
      user = User.find(decoded_token["sub"])

      user if user.present?
    rescue StandardError
      reject_unauthorized_connection
    end
  end
end
