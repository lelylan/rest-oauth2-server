module SettingsHelper

  # general
  HOST = "http://www.iana.org/domains/example"
  ANOTHER_HOST = "http://www.examplify.com"

  # resources
  USER_URI               = HOST + "/users/example"
  ANOTHER_USER_URI       = HOST + "/users/another"
  CLIENT_URI             = HOST + "/users/alice/client/lelylan"
  ANOTHER_CLIENT_URI     = HOST + "/users/alice/client/riflect"
  REDIRECT_URI           = HOST + "/app/callback"

  # scopes
  WRITE_SCOPE = ["pizza/read", "pizza/write", "pasta/read", "pasta/write"]
  READ_SCOPE  = ["pizza/read", "pasta/read"]


  # urls validator
  VALID_URIS    = [ 'http://example.com',  'http://www.example.com',
                    'https://example.com', 'https://www.example.com',
                    'http://example.host', 'https://example.host' ]
  INVALID_URIS  = [ 'ftp://godaddy.com',   'www.godaddy.com', 'godaddy.com', 'example' ]

end
