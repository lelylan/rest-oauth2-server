module Oauth2Provider
  class ClientsController < Oauth2Provider::ApplicationController
    before_filter :_oauth_provider_find_client, only: ["show", "edit", "update", "destroy", "block", "unblock"]
    before_filter :_oauth_provider_normalize_scope, only: ["create", "update"]
    before_filter :_oauth_provider_admin?, only: ["block", "unblock"]

    def index
      if current_user.admin?
        @clients = Oauth2Provider::Client.to_adapter.find_all({})
      else
        @clients = Oauth2Provider::Client.to_adapter.find_all(created_from: user_url(current_user))
      end
    end

    def show
    end

    def new
      @client = Client.new
      @client.scope = ["all"]
    end

    def create
      @client = Client.new(params[:client])
      @client.created_from = user_url(current_user)
      @client.uri          = @client.base_uri(request)
      @client.scope_values = Oauth2Provider.normalize_scope(params[:client][:scope].clone)

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
      @client.scope_values = Oauth2Provider.normalize_scope(params[:client][:scope].clone)

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

    def _oauth_provider_find_client
      attributes = { id: params[:id] }
      attributes.merge!(created_from: user_url(current_user)) unless current_user.admin?
      @client = Oauth2Provider::Client.to_adapter.find_first(attributes)
      unless @client
        redirect_to root_path, alert: "Resource not found."
      end
    end

    def _oauth_provider_normalize_scope
      params[:client][:scope] = params[:client][:scope].split(Oauth2Provider.settings["scope_separator"])
    end

  end
end
