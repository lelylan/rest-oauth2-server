class ScopesController < ApplicationController
 
  before_filter :find_resource, only: ["show", "edit", "update", "destroy"]

  def index
    @scopes = Scope.all
  end

  def show
  end

  def new
    @scope = Scope.new
  end

  def create
    @scope        = Scope.new(params[:scope])
    @scope.uri    = @scope.base_uri(request)
    @scope.values = @scope.normalize(params[:scope][:values])

    if @scope.save
      redirect_to(@scope, notice: "Resource was successfully created.")
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

    def find_resource
      @scope = Scope.criteria.id(params[:id]).first
      resource_not_found unless @scope
    end

    def resource_not_found
      flash.now.alert = "notifications.document.not_found"
      @info = { id: params[:id] }
      render "shared/html/404" and return
    end

end
