class UsersController < ApplicationController

  skip_before_filter :authenticate, only: ["new", "create"]
  before_filter :find_user, only: ["show", "edit", "update"]

  def show
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

  def edit
  end

  def update
    params[:user].delete_if { |key, value| key == "password" and value.empty? }
    if @user.update_attributes(params[:user])
      render "show"
    else
      render action: "edit"
    end
  end

  private 

    def find_user
      @user = User.where(uri: current_user.uri).id(params[:id]).first
      resource_not_found unless @user
    end

    def resource_not_found
      flash.now.alert = "notifications.document.not_found"
      @info = { id: params[:id] }
      render "shared/html/404" and return
    end 

end
