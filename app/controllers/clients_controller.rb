class ClientsController < ApplicationController

  before_filter :find_clients
  before_filter :find_client, only: ["show", "edit", "update", "destroy"]
  before_filter :normalize_scope, only: ["create", "update"]

  def index
  end

  def show
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(params[:client])
    @client.created_from = current_user.uri
    @client.uri = @client.base_uri(request)
    if @client.save
      redirect_to @client, notice: "Resource was successfully created."
    else
      render "new"
    end
  end

  def edit
  end

  def update
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


  private 

    def find_clients
      @clients = Client.where(created_from: current_user.uri)
    end

    def find_client
      @client = @clients.id(params[:id]).first
      resource_not_found unless @client
    end

    def resource_not_found
      flash.now.alert = "notifications.document.not_found"
      @info = { id: params[:id] }
      render "shared/html/404" and return
    end 

    def normalize_scope
      params[:client][:scope] = Oauth.normalize_scope(params[:client][:scope])
    end 

end
