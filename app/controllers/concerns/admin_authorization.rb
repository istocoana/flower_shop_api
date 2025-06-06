module AdminAuthorization
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
    rescue_from StandardError, with: :render_internal_error
  end

  def authorize_admin!
    render json: { error: "Access denied" }, status: :forbidden unless current_user&.admin?
  end

  def render_not_found(exception)
    render json: { error: "Resource not found", details: exception.message }, status: :not_found
  end

  def render_unprocessable_entity(exception)
    render json: { error: "Validation failed", details: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_internal_error(exception)
    Rails.logger.error(exception.full_message)
    render json: { error: "Internal server error", details: exception.message }, status: :internal_server_error
  end
end
