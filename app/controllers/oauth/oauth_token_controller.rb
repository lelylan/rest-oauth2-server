class Oauth::OauthTokenController < ApplicationController
  include ActionView::Helpers::DateHelper

  skip_before_filter :authenticate
  before_filter :json_body

  # authorization code flow
  before_filter :client_where_secret_and_redirect
  before_filter :find_authorization
  before_filter :find_authorization_expired

  # password credential flow
  before_filter :normalize_scope
  before_filter :client_where_secret
  before_filter :check_scope
  before_filter :find_resource_owner

  # refresh token flow
  before_filter :find_refresh_token
  before_filter :find_expired_token
  before_filter :token_blocked?

  before_filter :client_blocked?, only: "create"  # check if the client is blocked
  before_filter :access_blocked?, only: "create"  # check if user has blocked the client


  def create
    # section 4.1.3 - authorization code flow
    if @body[:grant_type] == "authorization_code"
      @token = OauthToken.create(client_uri: @client.uri, resource_owner_uri: @authorization.resource_owner_uri, scope: @authorization.scope)
      @refresh_token = OauthRefreshToken.create(access_token: @token.token)
      render "/oauth/token" and return
    end

    # section 4.3.1 (password credentials flow)
    if @body[:grant_type] == "password"
      @token = OauthToken.create(client_uri: @client.uri, resource_owner_uri: @resource_owner.uri, scope: @body[:scope])
      @refresh_token = OauthRefreshToken.create(access_token: @token.token)
      render "/oauth/token" and return
    end

    # section 6.0 (refresh token)
    if @body[:grant_type] == "refresh_token"
      @token = OauthToken.create(client_uri: @expired_token.client_uri, resource_owner_uri: @expired_token.resource_owner_uri, scope: @expired_token.scope)
      render "/oauth/token" and return
    end
  end

  # simulate a logout blocking the token
  # TODO: refactoring
  def destroy
    token = OauthToken.where(token: params[:id]).first
    if token
      token.block! 
      return head 200
    else
      return head 404
    end
  end


  private

    # filters for section 4.1.3 - authorization code flow
    def client_where_secret_and_redirect
      if @body[:grant_type] == "authorization_code"
        @client = Client.where_secret(@body[:client_secret], @body[:client_id]).where(redirect_uri: @body[:redirect_uri]).first
        message = "notifications.oauth.client.not_found"
        info = { client_secret: @body[:client_secret], client_id: @body[:client_id], redirect_uri: @body[:redirect_uri] }
        render_422 message, info unless @client
      end
    end

    def find_authorization
      if @body[:grant_type] == "authorization_code"
        @authorization = OauthAuthorization.where_code_and_client_uri(@body[:code], @client.uri).first
        @resource_owner_uri = @authorization.resource_owner_uri if @authorization
        message = "notifications.oauth.authorization.not_found"
        info = { code: @body[:code], client_id: @client.uri }
        render_422 message, info unless @authorization
      end
    end

    def find_authorization_expired
      if @body[:grant_type] == "authorization_code"
        message = "notifications.oauth.authorization.expired"
        info = { expired_at: @authorization.expire_at, description: distance_of_time_in_words(@authorization.expire_at, Time.now, true) }
        render_422 message, info if @authorization.expired?
      end
    end


    # filters for section 4.3.1 (password credentials flow)
    def normalize_scope
      if @body[:grant_type] == "password"
        @body[:scope] ||= ""
        @body[:scope] = Oauth.normalize_scope(@body[:scope])
      end
    end

    def client_where_secret
      if @body[:grant_type] == "password" or @body[:grant_type] == "refresh_token" 
        @client = Client.where_secret(@body[:client_secret], @body[:client_id])
        message = "notifications.oauth.client.not_found"
        info = { client_secret: @body[:client_secret], client_id: @body[:client_id] }
        render_422 message, info unless @client.first
      end
    end

    def check_scope
      if @body[:grant_type] == "password"
        @client = @client.where_scope(@body[:scope]).first
        message = "notifications.oauth.client.not_authorized"
        info = { scope: @body[:scope] }
        render_422 message, info unless @client
      end
    end

    def find_resource_owner
      if @body[:grant_type] == "password"
        @resource_owner = User.authenticate(@body[:username], @body[:password])
        @resource_owner_uri = @resource_owner.uri if @resource_owner
        message = "notifications.oauth.resource_owner.not_found"
        info = { username: @body[:username] }
        render_422 message, info unless @resource_owner
      end
    end


    # filters for refresh token (section 6.0)
    def find_refresh_token
      if @body[:grant_type] == "refresh_token"
        @client = @client.first
        @refresh_token = OauthRefreshToken.where(refresh_token: @body[:refresh_token]).first
        message = "notifications.oauth.refresh_token.not_found"
        info = { refresh_token: @body[:refresh_token] }
        render_422 message, info unless @refresh_token
      end
    end

    def find_expired_token
      if @body[:grant_type] == "refresh_token"
        @expired_token = OauthToken.where(token: @refresh_token.access_token).first
        @resource_owner_uri = @expired_token.resource_owner_uri
        message = "notifications.oauth.token.not_found"
        info = { token: @refresh_token.access_token }
        render_422 message, info unless @refresh_token
      end 
    end

    def token_blocked?
      if @body[:grant_type] == "refresh_token"
        message = "notifications.oauth.token.blocked_token"
        info = { token: @refresh_token.access_token }
        render_422 message, info if @expired_token.blocked?
      end 
    end


    # shared
    def client_blocked?
      message = "notifications.oauth.client.blocked"
      info = { client_id: @body[:client_id] }
      render_422 message, info if @client.blocked?
    end

    def access_blocked?
      access = OauthAccess.find_or_create_by(:client_uri => @client.uri, resource_owner_uri: @resource_owner_uri)
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
