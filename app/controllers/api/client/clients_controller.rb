class Api::Client::ClientsController < ActionController::Base
  before_filter :validate_params

  def fetch_combined
    timeout = params[:timeout].present? ? (params[:timeout].to_f / 1000) : nil
    data = Epoxy.new.get_data(timeout, params[:errors], 'appended')

    render json: data
  end

  def fetch_appended
    timeout = params[:timeout].present? ? (params[:timeout].to_f / 1000) : nil
    data = Epoxy.new.get_data(timeout, params[:errors], 'appended')

    render json: data
  end

  def validate_params
    head :bad_request unless params[:errors].present? && ['fail_any', 'replace'].include?(params[:errors])
  end
end
