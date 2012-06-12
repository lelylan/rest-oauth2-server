class Oauth2Provider::AccessesController < Oauth2Provider::ApplicationController

  before_filter :_oauth_provider_find_accesses
  before_filter :_oauth_provider_find_access, except: "index"

  def index
  end

  def show
  end

  def block
    @access.block!
    redirect_to oauth2_provider_engine.oauth2_provider_accesses_url
  end

  def unblock
    @access.unblock!
    redirect_to oauth2_provider_engine.oauth2_provider_accesses_url
  end


  private

    def _oauth_provider_find_accesses
      @accesses = Oauth2Provider::OauthAccess.where(resource_owner_uri: user_url(current_user))
    end

    def _oauth_provider_find_access
      @access = @accesses.where(:_id => params[:id]).first
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

