class Oauth2Provider::ClientsController < Oauth2Provider::ApplicationController
  before_filter :find_clients
  before_filter :find_client, only: ["show", "edit", "update", "destroy", "block", "unblock"]
  before_filter :normalize_scope, only: ["create", "update"]
  before_filter :admin?, only: ["block", "unblock"]

  def index
  end

  def show
  end

  def new
    @client = Client.new
    @client.scope = ["all"]
  end

  def create
    @client = Client.new(params[:client])
    @client.created_from = current_user.uri
    @client.uri          = @client.base_uri(request)
    @client.scope_values = OauthProvider.normalize_scope(params[:client][:scope].clone)

    if @client.save
      redirect_to oauth2_provider_engine.oauth2_provider_client_path( @client ), notice: "Resource was successfully created."
    else
      render "new"
    end
  end

  def edit
  end

  def update
    @client.scope = params[:client][:scope]
    @client.scope_values = OauthProvider.normalize_scope(params[:client][:scope].clone)

    if @client.update_attributes(params[:client])
      flash.now.notice = "Resource was successfully updated."
      render "show"
    else
      render action: "edit"
    end
  end

  def destroy
    @client.destroy
    redirect_to(clients_url, notice: "Resource was successfully destroyed.")
  end

  # TODO: this is not REST way
  def block
    @client.block!
    redirect_to oauth2_provider_engine.oauth2_provider_clients_url
  end

  def unblock
    @client.unblock!
    redirect_to oauth2_provider_engine.oauth2_provider_clients_url
  end


  private

    def find_clients
      if current_user.admin?
        @clients = Client.criteria
      else
        @clients = Client.where(created_from: current_user.uri)
      end
    end

    def find_client
      @client = @clients.where(_id: params[:id]).first
      unless @client
        redirect_to root_path, alert: "Resource not found."
      end
    end

    def normalize_scope
      params[:client][:scope] = params[:client][:scope].split(OauthProvider.settings["scope_separator"])
    end

    def admin?
      unless current_user.admin?
        flash.alert = "Unauthorized access."
        redirect_to root_path
        return false
      end
    end

end
