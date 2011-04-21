class SessionsController < ApplicationController

  skip_before_filter :authenticate

  def new
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

end
