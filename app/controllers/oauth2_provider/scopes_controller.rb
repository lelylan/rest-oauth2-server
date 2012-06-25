class Oauth2Provider::ScopesController < Oauth2Provider::ApplicationController

  before_filter :_oauth_provider_admin?
  before_filter :_oauth_provider_find_resource, only: ["show", "edit", "update", "destroy"]
  after_filter  :_oauth_provider_sync_existing_scopes, only: ["update", "destroy"]

  def index
    @scopes = Oauth2Provider::Scope.to_adapter.find_all({})
  end

  def show
  end

  def new
    @scope = Oauth2Provider::Scope.new
  end

  def create
    @scope        = Oauth2Provider::Scope.new(params[:scope])
    @scope.uri    = @scope.base_uri(request)
    @scope.values = @scope.normalize(params[:scope][:values])

    if @scope.save
      redirect_to(oauth2_provider_engine.oauth2_provider_scope_path(@scope), notice: "Resource was successfully created.")
    else
      render action: "new"
    end
  end

  def edit
  end

  def update
    @scope.values = @scope.normalize(params[:scope][:values])

    if @scope.update_attributes(params[:scope])
      render("show", notice: "Resource was successfully updated.")
    else
      render action: "edit"
    end
  end

  def destroy
    @scope.destroy
    redirect_to(scopes_url, notice: "Resource was successfully destroyed.")
  end


  private

  def _oauth_provider_find_resource
    @scope = Oauth2Provider::Scope.to_adapter.find_first(id: params[:id])
    unless @scope
      redirect_to root_path, alert: "Resource not found."
    end
  end

  # TODO: put into a background process
  def _oauth_provider_sync_existing_scopes
    Oauth2Provider::Client.sync_clients_with_scope(@scope.name)
  end

end
