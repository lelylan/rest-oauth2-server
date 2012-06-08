# TODO: define a yml file for configurations
module SettingsHelper

  # general
  HOST = "http://www.iana.org/domains/example"
  ANOTHER_HOST = "http://www.example.com"

  # resources
  USER_URI            = HOST + "/users/example"
  ANOTHER_USER_URI    = HOST + "/users/another"
  ADMIN_URI           = HOST + "/users/admin"
  CLIENT_URI          = HOST + "/users/alice/client/lelylan"
  ANOTHER_CLIENT_URI  = HOST + "/users/alice/client/riflect"
  REDIRECT_URI        = HOST + "/app/callback"

  # scopes
  SCOPE_URI   = HOST + "/scopes/pizzas"
  ALL_SCOPE   = ["pizzas/index", "pizzas/show", "pizzas/create", "pizzas/update", "pizzas/destroy"]
  READ_SCOPE  = ["pizzas/index", "pizzas/show"]


  # urls validator
  VALID_URIS    = [ 'http://example.com',  'http://www.example.com',
                    'https://example.com', 'https://www.example.com',
                    'http://example.host', 'https://example.host' ]
  INVALID_URIS  = [ 'ftp://godaddy.com',   'www.godaddy.com', 'godaddy.com', 'example' ]

end
