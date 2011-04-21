class Oauth::OauthAuthorizeController < ApplicationController

  before_filter :authenticate
  before_filter :normalize_scope
  before_filter :find_client
  before_filter :check_scope          # check if the access is authorized
  before_filter :client_blocked?      # check if the client is blocked
  before_filter :access_blocked?      # check if user has blocked the client

  before_filter :token_blocked?, only: :show   # check for an existing token
  before_filter :refresh_token,  only: :show   # create a new token


  def show
    render "/oauth/authorize" and return
  end

  def create
    @client.granted!

    # section 4.1.1 - authorization code flow
    if params[:response_type] == "code"
      @authorization = OauthAuthorization.create(client_uri: @client.uri, resource_owner_uri: current_user.uri, scope: params[:scope])
      redirect_to authorization_redirect_uri(@client, @authorization, params[:state])
    end

    # section 4.2.1 - implicit grant flow
    if params[:response_type] == "token"
      @token = OauthToken.create(client_uri: @client.uri, resource_owner_uri: current_user.uri, scope: params[:scope])
      redirect_to implicit_redirect_uri(@client, @token, params[:state])
    end
  end

  def destroy
    @client.revoked!
    redirect_to deny_redirect_uri(params[:response_type], params[:state])
  end


  private

    def normalize_scope
      params[:scope] = Oauth.normalize_scope(params[:scope])
    end


    def find_client
      @client = Client.where_uri(params[:client_id], params[:redirect_uri])
      client_not_found unless @client.first
    end

    def check_scope
      @client = @client.where_scope(params[:scope]).first
      scope_not_valid unless @client
    end

    def client_blocked?
      client_blocked if @client.blocked?
    end

    def access_blocked?
      access = OauthAccess.find_or_create_by(:client_uri => @client.uri, resource_owner_uri: current_user.uri)
      access_blocked if access.blocked?
    end
    
    def token_blocked?
      if params[:response_type] == "token"
        @token = OauthToken.exist(@client.uri, current_user.uri, params[:scope]).first
        token_blocked if @token and @token.blocked?
      end
    end

    # @only refresh token for implicit flow
    def refresh_token
      if @token
        @token = OauthToken.create(client_uri: @client.uri, resource_owner_uri: current_user.uri, scope: params[:scope])
        redirect_to implicit_redirect_uri(@client, @token, params[:state]) and return
      end
    end


    # helper methods

    def client_not_found
      flash.now.alert = I18n.t "notifications.oauth.client.not_found"
      @info = { client_id: params[:client_id], redirect_uri: params[:redirect_uri] }
      render "oauth/authorize" and return
    end

    def scope_not_valid
      flash.now.alert = I18n.t "notifications.oauth.client.not_authorized"
      @info = { scope: params[:scope] }
      render "oauth/authorize" and return
    end

    def client_blocked
      flash.now.alert = I18n.t "notifications.oauth.client.blocked"
      @info = { client_id: params[:client_id] }
      render "oauth/authorize" and return
    end

    def access_blocked
      flash.now.alert = I18n.t "notifications.oauth.resource_owner.blocked_client"
      @info = { client_id: params[:client_id] }
      render "oauth/authorize" and return
    end

    def token_blocked
      flash.now.alert = I18n.t "notifications.oauth.token.blocked_token"
      @info = { client_id: params[:client_id], token: @token.token }
      render "oauth/authorize" and return
    end

    def authorization_redirect_uri(client, authorization, state)
      uri  = client.redirect_uri
      uri += "?code="  + authorization.code
      uri += "&state=" + state if state
      return uri
    end

    def implicit_redirect_uri(client, token, state)
      uri  = client.redirect_uri
      uri += "#token=" + token.token
      uri += "&expires_in=" + Oauth.settings["token_expires_in"]
      uri += "&state=" + state if state
      return uri
    end

    def deny_redirect_uri(response_type, state)
      uri = @client.redirect_uri
      uri += (response_type == "code") ? "?" : "#"
      uri += "error=access_denied"
      uri += "&state=" + state if state
      return uri
    end

end
