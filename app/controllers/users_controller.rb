class UsersController < ApplicationController

  skip_before_filter :authenticate, only: ["new", "create"]
  before_filter :user_resources, only: ["show"]

  def show
    @user = @user_resources.id(params[:id]).first
    resource_not_found unless @user
  end

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

  private 

    def user_resources
      @user_resources = User.where(uri: current_user.uri)
    end

    def resource_not_found
      flash.now.alert = "notifications.document.not_found"
      @info = { id: params[:id] }
      render "shared/html/404" and return
    end 

end
