module ErrorHandling
  extend ActiveSupport::Concern

  class InvalidSortError < StandardError; end
  class InvalidFilterError < StandardError; end

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
    rescue_from InvalidSortError, with: :render_unprocessable_entity
    rescue_from InvalidFilterError, with: :render_unprocessable_entity
  end

  private

  def render_unprocessable_entity(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
end
