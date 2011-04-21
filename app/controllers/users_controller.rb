class UsersController < ApplicationController

  skip_before_filter :authenticate, only: ["new", "create"]
  before_filter :admin?, only: ["index"]
  before_filter :find_user, only: ["show", "edit", "update", "destroy"]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.uri = @user.base_uri(request)
    @user.admin = true if admin_does_not_exist
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
      @user = current_user.admin? ? User.criteria : User.where(uri: current_user.uri)
      @user = @user.id(params[:id]).first
      unless @user
        redirect_to root_path, alert: "Resource not found."
      end  
    end

    def admin?
      unless current_user.admin?
        flash.alert = "Unauthorized access."
        redirect_to root_path
        return false
      end
    end

end
