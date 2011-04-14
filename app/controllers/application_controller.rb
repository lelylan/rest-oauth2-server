class ApplicationController < ActionController::Base
  include Lelylan::Rescue::Helpers

  protect_from_forgery

  before_filter :authenticate
  helper_method :current_user

  rescue_from BSON::InvalidObjectId,        with: :bson_invalid_object_id
  rescue_from JSON::ParserError,            with: :json_parse_error
  rescue_from Mongoid::Errors::InvalidType, with: :mongoid_errors_invalid_type

  protected

    def json_body
      @body = HashWithIndifferentAccess.new(JSON.parse(request.body.read.to_s))
    end

    def authenticate
      if api_request
        # uncomment to make all json API protected
        #oauth_authorized
      else
        session_auth
      end
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

    def oauth_authorized
      action = params[:controller] + "/" + params[:action]
      normalize_token
      @token = OauthToken.where(token: params[:token]).all_in(scope: [action]).first
      if @token.nil? or @token.blocked?
        render text: "Unauthorized access", status: 401
        return false
      end
    end

    def normalize_token
      if ["create", "update", "destroy"].include?(params[:action])
        json_body unless @body
        params[:token] = @body[:token]
      end
    end

end
