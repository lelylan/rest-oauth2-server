class AccessesController < ApplicationController

  before_filter :find_accesses
  before_filter :find_access, except: "index"

  def index
  end

  def show
  end

  def block
    @access.block!
    redirect_to accesses_url
  end

  def unblock
    @access.unblock!
    redirect_to accesses_url
  end


  private 
  
    def find_accesses
      @accesses = OauthAccess.where(resource_owner_uri: current_user.uri)
    end

    def find_access
      @access = @accesses.id(params[:id]).first
      unless @access
        redirect_to root_path, alert: "Resource not found."
      end
    end

    # TODO: change this behavior with a simple redirect
    def resource_not_found
      flash.now.alert = "notifications.document.not_found"
      @info = { id: params[:id] }
      render "shared/html/404" and return
    end 

end
