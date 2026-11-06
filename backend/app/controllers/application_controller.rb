class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |error|
    render json: { error: "#{error.model || 'Record'} not found" }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |error|
    render json: { error: error.message }, status: :bad_request
  end

  private

  def render_unprocessable(record)
    render json: { errors: record.errors }, status: :unprocessable_entity
  end
end
