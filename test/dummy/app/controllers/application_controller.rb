class ApplicationController < ActionController::Base
  include Oauth2Provider::ControllerMixin

  protect_from_forgery

  before_filter :authenticate
  helper_method :current_user
  helper_method :admin_does_not_exist

  rescue_from BSON::InvalidObjectId,        with: :bson_invalid_object_id
  rescue_from JSON::ParserError,            with: :json_parse_error
  rescue_from Mongoid::Errors::InvalidType, with: :mongoid_errors_invalid_type

  protected

  def session_auth
    @current_user ||= User.where(:_id => session[:user_id]).first if session[:user_id]
    unless current_user
      session[:back] = request.url
      redirect_to(log_in_path) and return false
    end
    return @current_user
  end

  def current_user
    @current_user
  end

  def admin_does_not_exist
    User.where(admin: true).first.nil?
  end

  def bson_invalid_object_id(e)
    redirect_to root_path, alert: "Resource not found."
  end

  def json_parse_error(e)
    redirect_to root_path, alert: "Json not valid"
  end

  def mongoid_errors_invalid_type(e)
    redirect_to root_path, alert: "Json values is not an array"
  end
end
