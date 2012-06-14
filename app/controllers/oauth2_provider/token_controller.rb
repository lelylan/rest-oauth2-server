class Oauth2Provider::TokenController < Oauth2Provider::ApplicationController
  include ActionView::Helpers::DateHelper

  skip_before_filter :_oauth_provider_authenticate
  before_filter      :_oauth_provider_json_body

  # authorization code flow
  before_filter :_oauth_provider_client_where_secret_and_redirect
  before_filter :_oauth_provider_find_authorization
  before_filter :_oauth_provider_find_authorization_expired

  # password credential flow
  before_filter :_oauth_provider_normalize_scope
  before_filter :_oauth_provider_client_where_secret
  before_filter :_oauth_provider_check_scope
  before_filter :_oauth_provider_find_resource_owner

  # refresh token flow
  before_filter :_oauth_provider_find_refresh_token
  before_filter :_oauth_provider_find_expired_token
  before_filter :_oauth_provider_token_blocked?

  before_filter :_oauth_provider_client_blocked?, only: "create"  # check if the client is blocked
  before_filter :_oauth_provider_access_blocked?, only: "create"  # check if user has blocked the client


  def create
    # section 4.1.3 - authorization code flow
    if @body[:grant_type] == "authorization_code"
      @token = Oauth2Provider::OauthToken.to_adapter.create!(client_uri: @client.uri, resource_owner_uri: @authorization.resource_owner_uri, scope: @authorization.scope)
      @refresh_token = Oauth2Provider::OauthRefreshToken.to_adapter.create!(access_token: @token.token)
      render "/shared/token" and return
    end

    # section 4.3.1 (password credentials flow)
    if @body[:grant_type] == "password"
      @token = Oauth2Provider::OauthToken.to_adapter.create!(client_uri: @client.uri, resource_owner_uri: user_url(@resource_owner), scope: @body[:scope])
      @refresh_token = Oauth2Provider::OauthRefreshToken.to_adapter.create!(access_token: @token.token)
      render "/shared/token" and return
    end

    # section 6.0 (refresh token)
    if @body[:grant_type] == "refresh_token"
      @token = Oauth2Provider::OauthToken.to_adapter.create!(client_uri: @expired_token.client_uri, resource_owner_uri: @expired_token.resource_owner_uri, scope: @expired_token.scope)
      render "/shared/token" and return
    end
  end

  # simulate a logout blocking the token
  # TODO: refactoring
  def destroy
    token = Oauth2Provider::OauthToken.to_adapter.find_first(token: params[:id])
    if token
      token.block!
      return head 200
    else
      return head 404
    end
  end


  private

  # filters for section 4.1.3 - authorization code flow
  def _oauth_provider_client_where_secret_and_redirect
    if @body[:grant_type] == "authorization_code"
      @client = Oauth2Provider::Client.to_adapter.find_first(secret: @body[:client_secret], uri: @body[:client_id], redirect_uri: @body[:redirect_uri])
      message = "notifications.oauth.client.not_found"
      info = { client_secret: @body[:client_secret], client_id: @body[:client_id], redirect_uri: @body[:redirect_uri] }
      render_422 message, info unless @client
    end
  end

  def _oauth_provider_find_authorization
    if @body[:grant_type] == "authorization_code"
      @authorization = Oauth2Provider::OauthAuthorization.where_code_and_client_uri(@body[:code], @client.uri).first
      @resource_owner_uri = @authorization.resource_owner_uri if @authorization
      message = "notifications.oauth.authorization.not_found"
      info = { code: @body[:code], client_id: @client.uri }
      render_422 message, info unless @authorization
    end
  end

  def _oauth_provider_find_authorization_expired
    if @body[:grant_type] == "authorization_code"
      message = "notifications.oauth.authorization.expired"
      info = { expired_at: @authorization.expire_at, description: distance_of_time_in_words(@authorization.expire_at, Time.now, true) }
      render_422 message, info if @authorization.expired?
    end
  end


  # filters for section 4.3.1 (password credentials flow)
  def _oauth_provider_normalize_scope
    if @body[:grant_type] == "password"
      @body[:scope] ||= ""
      @body[:scope] = Oauth2Provider.normalize_scope(@body[:scope])
    end
  end

  def _oauth_provider_client_where_secret
    if @body[:grant_type] == "password" or @body[:grant_type] == "refresh_token"
      @client = Oauth2Provider::Client.to_adapter.find_first(secret: @body[:client_secret], uri: @body[:client_id])
      message = "notifications.oauth.client.not_found"
      info = { client_secret: @body[:client_secret], client_id: @body[:client_id] }
      render_422 message, info unless @client
    end
  end

  def _oauth_provider_check_scope
    if @body[:grant_type] == "password"
      @client = Oauth2Provider::Client.to_adapter.find_all(secret: @body[:client_secret], uri: @body[:client_id]).detect{|c|c.scope_values.sort == @body[:scope].sort}
      message = "notifications.oauth.client.not_authorized"
      info = { scope: @body[:scope] }
      render_422 message, info unless @client
    end
  end

  def _oauth_provider_find_resource_owner
    if @body[:grant_type] == "password"
      @resource_owner = User.authenticate(@body[:username], @body[:password])
      @resource_owner_uri = user_url(@resource_owner) if @resource_owner
      message = "notifications.oauth.resource_owner.not_found"
      info = { username: @body[:username] }
      render_422 message, info unless @resource_owner
    end
  end


  # filters for refresh token (section 6.0)
  def _oauth_provider_find_refresh_token
    if @body[:grant_type] == "refresh_token"
      @refresh_token = Oauth2Provider::OauthRefreshToken.where(refresh_token: @body[:refresh_token]).first
      message = "notifications.oauth.refresh_token.not_found"
      info = { refresh_token: @body[:refresh_token] }
      render_422 message, info unless @refresh_token
    end
  end

  def _oauth_provider_find_expired_token
    if @body[:grant_type] == "refresh_token"
      @expired_token = Oauth2Provider::OauthToken.where(token: @refresh_token.access_token).first
      @resource_owner_uri = @expired_token.resource_owner_uri
      message = "notifications.oauth.token.not_found"
      info = { token: @refresh_token.access_token }
      render_422 message, info unless @refresh_token
    end
  end

  def _oauth_provider_token_blocked?
    if @body[:grant_type] == "refresh_token"
      message = "notifications.oauth.token.blocked_token"
      info = { token: @refresh_token.access_token }
      render_422 message, info if @expired_token.blocked?
    end
  end


  # shared
  def _oauth_provider_client_blocked?
    message = "notifications.oauth.client.blocked"
    info = { client_id: @body[:client_id] }
    render_422 message, info if @client.blocked?
  end

  def _oauth_provider_access_blocked?
    access = Oauth2Provider::OauthAccess.find_or_create_by(:client_uri => @client.uri, resource_owner_uri: @resource_owner_uri)
    message =  "notifications.oauth.resource_owner.blocked_client"
    info = { client_id: @body[:client_id] }
    render_422 message, info if access.blocked
  end

  # visualization
  def render_404(message, info)
    @message = I18n.t message
    @info    = info.to_s
    render "shared/404", status: 404 and return
  end

  def render_422(message, info)
    @message = I18n.t message
    @info    = info.to_json
    render "shared/422", status: 422 and return
  end

end
