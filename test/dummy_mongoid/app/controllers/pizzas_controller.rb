class PizzasController < ApplicationController
  before_filter :oauth_authorized

  def index
    render json: {action: :index}
  end

  def show
    render json: {action: :show}
  end

  def create
    render json: {action: :create}
  end

  def update 
    render json: {action: :update}
  end

  def destroy
    render json: {action: :destroy}
  end
end
