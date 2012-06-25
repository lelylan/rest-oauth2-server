class ApplicationController < ActionController::Base
  include Oauth2Provider::ControllerMixin

  protect_from_forgery
  helper_method :current_user_session, :current_user
  before_filter :require_user

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
    @current_user
  end

  def require_user
    if api_request
      oauth_authorized
    else
      unless current_user
        flash[:notice] = "You must be logged in to access this page"
        session[:return_url] = request.fullpath
        redirect_to new_user_session_url
      end
    end
  end

  def require_no_user
    if current_user
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_url
      return false
    end
  end
end
