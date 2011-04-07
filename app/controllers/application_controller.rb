class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :authenticate
  helper_method :current_user

  protected

    def json_body
      @body = HashWithIndifferentAccess.new(JSON.parse(request.body.read.to_s))
    end

    def authenticate
      api_request ? basic_auth : session_auth
    end

    def api_request
      json?
    end

    def json?
      request.format == "application/json"
    end

    def basic_auth
      authenticate_or_request_with_http_basic do |username, password|
        user = User.where(email: username).first
        if user and user.verify(password)
          @current_user = user
        else
          false
        end
      end
    end

    def session_auth
      @current_user ||= User.criteria.id(session[:user_id]).first if session[:user_id]
      unless current_user
        redirect_to(log_in_path) and return false
      end
    end

    def current_user
      @current_user
    end

end
