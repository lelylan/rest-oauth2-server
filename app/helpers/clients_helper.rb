module ClientsHelper
  def authorization_uri(client, scope)
    "/oauth/authorize?response_type=code&scope=#{scope}&client_id=#{client.uri}&redirect_uri=#{client.redirect_uri}"
  end
end
