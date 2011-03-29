class UsersController < ApplicationController

  skip_before_filter :authenticate

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.link = @user.base_link(request)
    if @user.save
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
  end

end
