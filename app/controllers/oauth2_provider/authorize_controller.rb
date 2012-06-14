class Oauth2Provider::AuthorizeController < Oauth2Provider::ApplicationController

  before_filter :_oauth_provider_authenticate
  before_filter :_oauth_provider_normalize_scope
  before_filter :_oauth_provider_find_client
  before_filter :_oauth_provider_check_scope          # check if the access is authorized
  before_filter :_oauth_provider_client_blocked?      # check if the client is blocked
  before_filter :_oauth_provider_access_blocked?      # check if user has blocked the client

  before_filter :_oauth_provider_token_blocked?, only: :show   # check for an existing token
  before_filter :_oauth_provider_refresh_token,  only: :show   # create a new token


  def show
    render "shared/authorize" and return
  end

  def create
    @client.granted!

    # section 4.1.1 - authorization code flow
    if params[:response_type] == "code"
      @authorization = Oauth2Provider::OauthAuthorization.to_adapter.create!(client_uri: @client.uri, resource_owner_uri: user_url(current_user), scope: params[:scope])
      redirect_to authorization_redirect_uri(@client, @authorization, params[:state])
    end

    # section 4.2.1 - implicit grant flow
    if params[:response_type] == "token"
      @token = Oauth2Provider::OauthToken.to_adapter.create!(client_uri: @client.uri, resource_owner_uri: user_url(current_user), scope: params[:scope])
      redirect_to implicit_redirect_uri(@client, @token, params[:state])
    end
  end

  def destroy
    @client.revoked!
    redirect_to deny_redirect_uri(@client, params[:response_type], params[:state])
  end


  private

    def _oauth_provider_normalize_scope
      params[:scope] = Oauth2Provider.normalize_scope(params[:scope])
    end


    def _oauth_provider_find_client
      @clients = Oauth2Provider::Client.to_adapter.find_all(uri: params[:client_id], redirect_uri: params[:redirect_uri])
      client_not_found if @clients.empty?
    end

    def _oauth_provider_check_scope
      scopes = params[:scope].sort
      @client = @clients.detect{|c|c.scope_values.sort == scopes}
      scope_not_valid unless @client
    end

    def _oauth_provider_client_blocked?
      client_blocked if @client.blocked?
    end

    def _oauth_provider_access_blocked?
      attributes = {client_uri: @client.uri, resource_owner_uri: user_url(current_user)}
      access = Oauth2Provider::OauthAccess.to_adapter.find_first(attributes)
      access = Oauth2Provider::OauthAccess.to_adapter.create!(attributes) unless access
      access_blocked if access.blocked?
    end

    def _oauth_provider_token_blocked?
      if params[:response_type] == "token"
        @token = Oauth2Provider::OauthToken.to_adapter.find_all(client_uri: @client.uri, resource_owner_uri: user_url(current_user)).detect{|t|t.scope.sort == params[:scope].sort}
        token_blocked if @token and @token.blocked?
      end
    end

    # @only refresh token for implicit flow
    def _oauth_provider_refresh_token
      if @token
        @token = Oauth2Provider::OauthToken.to_adapter.create!(client_uri: @client.uri, resource_owner_uri: user_url(current_user), scope: params[:scope])
        redirect_to implicit_redirect_uri(@client, @token, params[:state]) and return
      end
    end


    # helper methods

    def client_not_found
      flash.now.alert = I18n.t "notifications.oauth.client.not_found"
      @info = { client_id: params[:client_id], redirect_uri: params[:redirect_uri] }
      render "shared/authorize" and return
    end

    def scope_not_valid
      flash.now.alert = I18n.t "notifications.oauth.client.not_authorized"
      @info = { scope: params[:scope] }
      render "shared/authorize" and return
    end

    def client_blocked
      flash.now.alert = I18n.t "notifications.oauth.client.blocked"
      @info = { client_id: params[:client_id] }
      render "shared/authorize" and return
    end

    def access_blocked
      flash.now.alert = I18n.t "notifications.oauth.resource_owner.blocked_client"
      @info = { client_id: params[:client_id] }
      render "shared/authorize" and return
    end

    def token_blocked
      flash.now.alert = I18n.t "notifications.oauth.token.blocked_token"
      @info = { client_id: params[:client_id], token: @token.token }
      render "shared/authorize" and return
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
      uri += "&expires_in=" + Oauth2Provider.settings["token_expires_in"]
      uri += "&state=" + state if state
      return uri
    end

    def deny_redirect_uri(client, response_type, state)
      uri = client.redirect_uri
      uri += (response_type == "code") ? "?" : "#"
      uri += "error=access_denied"
      uri += "&state=" + state if state
      return uri
    end

end
