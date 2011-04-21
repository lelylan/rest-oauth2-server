class SessionsController < ApplicationController

  before_filter :check_authentication, only: "new"
  skip_before_filter :authenticate

  def new
    puts "::::" + current_user.inspect
    redirect_to current_user if current_user
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      session[:back] ||= user_path(user)
      redirect_to session[:back], notice: "Logged in!"
      session[:back] = nil
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end

  private 

    def check_authentication
      session_auth
    end

end
