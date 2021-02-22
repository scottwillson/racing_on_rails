# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    render status: 404
  end

  def internal_server_error
    render status: 500
  end

  def over_capacity
    render status: 503
  end

  def unauthorized
    render status: 401
  end

  def unprocessable_entity
    render status: 422
  end
end
