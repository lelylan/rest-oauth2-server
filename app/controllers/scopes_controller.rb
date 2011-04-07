class ScopesController < ApplicationController
 
  before_filter :json_body, only: ["create", "update"]
  before_filter :find_resource, only: ["show", "update", "destroy"]

  def index
    @scopes = Scope.all.paginate page: params[:page], per_page: params[:per_page]
  end

  def show
  end

  def create
    @scope = scope.base(@body, request, current_user)
    if @scope.save
      render "show", status: 201, location: @scope.uri
    else
      render_422 "notifications.document.not_valid", @scope.errors
    end
  end

  def update
    if @scope.update_attributes(@body)
      render "show", status: 200, location: @scope.uri
    else
      render_422 "notifications.document.not_valid", @scope.errors
    end
  end

  def destroy
    @scope.destroy
    head 204
  end


  private

    def find_resource
      @scope = Scope.criteria.id(params[:id]).first
      resource_not_found unless @scope
    end

    def resource_not_found
      flash.now.alert =  "notifications.document.not_found"
      @info = params[:id]
      render "shared/404" and return
    end
 
end
