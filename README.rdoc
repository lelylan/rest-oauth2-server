http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/help-us.png

{The Lelylan Team}[http://lelylan.com]


= Rest OAuth 2.0 Server

<b>Rest OAuth 2.0 Server</b> is a project that easily allows the generation of an OAuth 2.0 Server following the {draft 13}[http://tools.ietf.org/html/draft-ietf-oauth-v2-13]
of the OAuth 2.0 protocol with {bearer tokens}[http://tools.ietf.org/html/draft-ietf-oauth-v2-bearer-02]. The spec 
is close to settling down, and we intend to update our code to match the final OAuth 2.0 and bearer token standards. 
OAuth has often been described as a "valet key for the web." It lets applications ask users for access to just the 
data they need and no more, giving them the ability to enable and disable the accesses whenever they want, most of 
the time without sharing their secret credentials.


= Installation

For the Rest OAuth 2.0 Server to work you need to have

* {Ruby 1.9.2}[www.ruby-lang.org/en/] (use rvm[http://screencasts.org/episodes/how-to-use-rvm?utm_source=rubyweekly&utm_medium=email] to manage versions).
* {MongoDB}[http://www.mongodb.org/]. 

To install the project run the following commands (remember to run <tt>$ mongod</tt> before)

  $ git clone git@github.com:Lelylan/rest-oauth2-server.git
  $ cd rest-oauth2-server
  $ bundle install
  $ rake spec
  $ rails s

If everything works fine, you have your OAuth 2.0 Server up and running! We are also working at a gem and a 
generator to easily integrate the Rest OAuth 2.0 server into your project, so stay tuned.


== Admin user definition

When accessing the application for the first time, click to sign up. A message will ask you to create the first 
administrator user as no one have been found. 

http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/screenshots/first-user-creation.png

Register, log in and access the admin dashboard where you will find the following sections.

* <b>Users</b>: list with all registered users.
* <b>Scopes</b>: authorization scopes administration.
* <b>Accesses</b>: clients that access the user's data.
* <b>Clients</b>: registered clients (third party application)

While the Users and Scopes sections are visible only to the admin, Accesses and Clients are available to every 
registered user, also the ones that will grant access for their resources. To better understand what you can do 
explore the Dashboard and read the following sections.

http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/screenshots/admin-dashboard.png


== Scopes explained

In a short way, scopes tell you <b>what can and can't be accessed</b>. The Rest OAuth 2.0 Server ships with a 
flexible and powerful scope system which can be dynamically built.

http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/screenshots/scopes.png

To create a new scope click <b>Create a new scope</b> and you will get a simple form with two fields

* <b>Name</b>: unique alphanumeric key that identify a scope.
* <b>Values</b>: list of space separated alphanumeric strings, each of one refers to an action (built following the convention <b>{controller name}/{action name}</b>) or to an existing scope name. 

Going a bit deeper you can define the accessible actions in two ways. 

=== Action specific values

You can specify *any* action present in your rails app. For example if you want to allow the access to the action 
create in the controller pizzas you just add the string "pizzas/create". Here you can see an example on defining the 
access to all RESTful actions in a sample pizzas controller.

http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/screenshots/pizzas-scope.png

=== Scope name values

You can specify any group of actions adding a name scope. For example if the scope pizzas allows the access to all 
actions in the pizzas controller and the scope pastas allow the access to all actions in pastas controller, then the 
"all" "cope could have as values the list "pizzas pastas"

http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/screenshots/all-scope.png


== Protect your resources

After scopes are defined there is one more step. You need to protect the actions you want to authorize. To do thi
add the filter <tt>oauth_authorized</tt> in any controller you want to protect.

  class PizzasController < ApplicationController
    before_filter :oauth_authorized
    ...

This filter verify if the client can access the specific action, regarding the scope that has been granted from the user.
You can also decide to protect all of your resources (they must accept JSON format) by uncommenting <tt>oauth_authorized</tt> 
line in the {ApplicationController}[https://github.com/Lelylan/rest-oauth2-server/blob/master/app/controllers/application_controller.rb].

Last, you can make some actions public by using the <tt>exclude</tt> option.

   before_filter :oauth_authorized, except: %w(index, show)


== Client definition

Every registered user can define a client (third party application). To do this access the dashboard and create your first 
client filling these fields.

* <b>Name</b>: client name.
* <b>Siti URI</b>: client web site URI.
* <b>Redirect URI</b>: client redirect URI, used as callback after the user grant or deny the access.
* <b>Scope</b>: one or more scope names, separated by spaces (limit the possible accesses a client can have). By default a
scope named "all" is set as default. For this reason follow the convention to call "all" the scope that give all accesses.
* <b>Info</b>: additional information.

Once the client is create the additional field <b>client uri</b> and <b>secret</b> are generated. You will use these info
later on, during the authorization flows.

http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/screenshots/client-show.png

If you define a scope named <b>all</b> you can use one more functionality. You can click the button <b>Simulate Authorization</b>
that you can find in the end of the client detail page, and you will see the authorization page that a user would normally see 
when granting access to a client.

http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/screenshots/authorization.png


=== Block clients

The admin can access to all created clients and decide to block any of them, meaning all related access tokens are disabled. 
This is pretty useful in cases where a client is considered "not safe". When a client is blocked every authorization request
will be disabled, until the admin unblock it.

http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/screenshots/block-clients.png


== Granted Clients (aka accesses)

Once users grant the access to their resources, the accesses list is updated. Here a user can see which clients are accessing
their resources, and with which frequency. One important functionality lies on the possibility for a user to block a specific 
client, whenever it is considered "not safe".

http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/screenshots/access.png




= OAuth 2.0 flows explained

Today Rest OAuth 2.0 Server supports three flows of OAuth 2.0
* The server-side flow for web applications with servers that can securely store persistent information ({Authorization Code Flow}[http://tools.ietf.org/html/draft-ietf-oauth-v2-13#section-4.1])
* The client-side flow for JavaScript applications running in a browser ({Implicit Grant Flow}[http://tools.ietf.org/html/draft-ietf-oauth-v2-13#section-4.2]) 
* The native application flow for desktop and mobile applications ({Resource Owner Password Credentials Flow}[http://tools.ietf.org/html/draft-ietf-oauth-v2-13#section-4.3])


== OAuth 2.0 for server-side web applications

This flow is meant for web applications with servers that can keep secrets and maintain state. 

The server-side flow has two parts. In the first part, your application asks the user for permission to access 
their data. If the user approves, instead of sending an access token directly as in the client-side flow, the 
Rest OAuth 2.0 Server will send to the client an authorization code. In the second part, the client will POST 
that code along with its client secret to the Rest OAuth 2.0 Server in order to get the access token.

=== Getting an access token

This flow begins by sending the user to the authorization endpoint <tt>/oauth/authorization</tt>
with the following query parameters

* <b>response_type</b> (REQUIRED): always use "code" as response type
* <b>client_id</b> (REQUIRED): client identifier (the URI of the client model)
* <b>redirect_uri</b> (REQUIRED): callback URI to the client application
* <b>scope</b> (REQUIRED): privileges given to the client
* <b>state</b> (OPTIONAL): opaque value used by the client to maintain state between the request and callback

Here's an example URL for a hypothetical app called "Example App" running on https://www.example.com

  http://localhost:3000/oauth/authorization?
    response_type=code&
    client_id=http://localhost:3000/clients/a918F2fs3&
    redirect_uri=httsp://www.example.com/callback&
    scope=write&
    state=2af5D3vds

And this is what you should see.

http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/screenshots/authorization.png

After the user approves access or chooses not to, we'll redirect to the <tt>redirect_uri</tt> you pass us. If the 
user denies access, an error code is appended:

  https://example.com/callback?error=access_denied&state=2af5D3vds

If the user approves access will be appended an authorization code in the query string of the URL:

  https://example.com/callback?code=g2VDXwrT0S6iZeUeYQBYi2stxRy&state=2af5D3vds

Now, the client reached through the <tt>redirect_uri</tt> should swap that authorization code for an access token by POSTing 
it along the following params to the token endpoint <tt>/oauth/token</tt> using the JSON format.

* <b>code</b> (REQUIRED): authorization code (from the previous step)
* <b>grant_type</b> (REQUIRED): always use "authorization_code" as grant type
* <b>client_id</b> (REQUIRED): client identifier (in our case is the uri field of the client)
* <b>client_secred</b> (REQUIRED): client secret code

Using curl the request might look like:
 
  curl -i http://localhost:3000/oauth/token \
       -H "Accept: application/json" \
       -X POST -d '{
          "code": "g2VDXwrT0S6iZeUeYQBYi2stxRy", \
          "grant_type": "authorization_code", \
          "client_id": "http://localhost:30000/clients/a918F2fs3", \
          "client_secret": "a34a7afe4731e745de9d61iZeUeY" \
       }'

The response is a JSON Object containing the access token:

  { 
    "access_token": "SlAV32hkKG", 
    "expires_in": 1800,
    "refresh_token": "Da8i1930LSj"
  }

=== Getting additional access tokens

When your access token expires, Rest OAuth 2.0 Server API endpoints will respond with HTTP 401 Unauthorized. At any time, 
you can use the token endpoint with your refresh token with the following query parameters

* <b>grant_type</b> (REQUIRED): always use "refresh_token" as grant type
* <b>client_id</b> (REQUIRED): client identifier (in our case is the uri field of the client)
* <b>client_secred</b> (REQUIRED): client secret code
* <b>refresh_token</b> (REQUIRED): refresh token previusly received

Using curl the request might look like:
 
  curl -i http://localhost:3000/oauth/token \
       -H "Accept: application/json" \
       -X POST -d '{
          "grant_type": "refresh_token", \
          "refresh_token": "Da8i1930LSj", \
          "client_id": "http://localhost:30000/clients/a918F2fs3", \
          "client_secret": "a34a7afe4731e745de9d61iZeUeY" \
       }'

The response is a JSON Object containing the new access token. 

  { 
    "access_token": "AlYZ892hsKs", 
    "expires_in": 1800,
    "refresh_token": "Da8i1930LSj"
  }


=== Going deep

If you are curious and you want to find more check the {acceptance}[https://github.com/Lelylan/rest-oauth2-server/blob/master/spec/acceptance/oauth/oauth_authorize_controller_spec.rb] 
{tests}[https://github.com/Lelylan/rest-oauth2-server/blob/master/spec/acceptance/oauth/oauth_token_controller_spec.rb] 
in the <b>authorization token flow</b> and <b>refresh token</b> context.



== OAuth 2.0 for client-side web applications

This flow is meant for JavaScript-based web applications that can't maintain state over time (it includes also ActionScript 
and SilverLight).

=== Getting a user's permission


This flow begins by sending the user to the authorization endpoint <tt>/oauth/authorization</tt>
with the following query parameters

* <b>response_type</b> (REQUIRED): always use "token" as response type
* <b>client_id</b> (REQUIRED): client identifier (the uri of the client model)
* <b>redirect_uri</b> (REQUIRED): callback URI to the client application
* <b>scope</b> (REQUIRED): privileges given to the client
* <b>state</b> (OPTIONAL): opaque value used by the client to maintain state between the request and callback

Here's an example URL for a hypothetical app called "Example App" running on https://www.example.com

  http://localhost:3000/oauth/authorization?
    response_type=token&
    client_id=http://localhost:3000/clients/a918F2fs3&
    redirect_uri=httsp://www.example.com/callback&
    scope=write&
    state=2af5D3vds

And this is what you should see.

http://github.com/Lelylan/rest-oauth2-server/raw/development/public/images/screenshots/authorization.png

After the user approves access or chooses not to, we'll redirect to the <tt>redirect_uri</tt> you pass. If the 
user denies access, an error code is appended:

  https://example.com/callback#error=access_denied&state=2af5D3vds

If the user approves will be appended an access token in the hash fragment of the UR:

  https://example.com/callback#token=g2VDXwrT0S6iZeUeYQBYi2stxRy&expires_in=1800&state=2af5D3vds

JavaScript running on that page can grab that access token from the <tt>window.location.hash</tt> and either store it in a
cookie or POST it to a server. Note that the token is added to the {fragment URI}[http://en.wikipedia.org/wiki/Fragment_identifier]. 
This is done because the fragment URI can not be read from server side, but only from client-based applications.

=== Getting additional access tokens

When your access token expires, our API endpoints will respond with HTTP 401 Unauthorized. At any time, you can send 
your user to the same authorization endpoint you used in the previous step. If the user has already authorized your 
application for the scopes you're requesting, Rest OAuth Server won't show the OAuth dialog and will immediately redirect 
to the <tt>redirect_uri</tt> you pass us with a new access token.

=== Going deep

If you are curious and you want to find more check the {acceptance tests}[https://github.com/Lelylan/rest-oauth2-server/blob/master/spec/acceptance/oauth/oauth_authorize_controller_spec.rb] 
in the <b>implicit token flow</b> and <b>refresh implicit token flow</b> context.



== OAuth 2.0 for native applications

This flow is meant for mobile, and desktop installed applications that want access to user data (native apps).

This flow is suitable in cases where the resource owner has a trust relationship with the client, such as its computer operating 
system or a highly privileged application. The authorization server should take special care when enabling the grant type, and 
<b>only when other flows are not viable</b>, because username and password are shared with the client.

=== Getting an access token

The client should POST to the token endpoint <tt>/oauth/token</tt> along with the following params
using the JSON format:

* <b>grant_type</b> (REQUIRED): always use "password" as grant type
* <b>username</b> (REQUIRED): resource owner email address
* <b>password</b> (REQUIRED): resource owner password
* <b>client_id</b> (REQUIRED): client identifier (the uri of the client model)
* <b>redirect_uri</b> (REQUIRED): callback URI to the client application
* <b>scope</b> (REQUIRED): privileges given to the client

Using curl the request might look like:

  curl -i http://localhost:3000/oauth/token \
       -H "Accept: application/json" \
       -X POST -d '{
          "grant_type": "password", \
          "client_id": "http://localhost:3000/clients/a918F2fs3", \
          "client_secret": "a34a7afe4731e745de9d61iZeUeY", \
          "username": "alice@example.com", \
          "password": "example", \
          "scope": "write" \
       }'
       
The response is a JSON Object containing the access token:

  { 
    "access_token": "AlYZ892hsKs", 
    "expires_in": 1800,
    "refresh_token": "Da8i1930LSj"
  }

=== Getting additional access tokens

When your access token expires, Rest OAuth 2.0 Server API endpoints will respond with HTTP 401 Unauthorized. At any time, 
you can use the token endpoint with your refresh token with the following query parameters

* <b>grant_type</b> (REQUIRED): always use "refresh_token" as grant type
* <b>client_id</b> (REQUIRED): client identifier (in our case is the uri field of the client)
* <b>client_secred</b> (REQUIRED): client secret code
* <b>refresh_token</b> (REQUIRED): refresh token previusly received

Using curl the request might look like:
 
  curl -i http://localhost:3000/oauth/token \
       -H "Accept: application/json" \
       -X POST -d '{
          "grant_type": "refresh_token", \
          "refresh_token": "Da8i1930LSj", \
          "client_id": "http://localhost:30000/clients/a918F2fs3", \
          "client_secret": "a34a7afe4731e745de9d61iZeUeY" \
       }'

The response is a JSON Object containing the new access token. 

  { 
    "access_token": "AlYZ892hsKs", 
    "expires_in": 1800,
    "refresh_token": "Da8i1930LSj"
  }

=== Going deep

If you are curious and you want to find more check the {acceptance tests}[https://github.com/Lelylan/rest-oauth2-server/blob/master/spec/acceptance/oauth/oauth_token_controller_spec.rb] 
in the <b>password credentials flow</b> and <b>refresh token</b> context.



= How to use Access Token

To make API requests on the behalf of a user, pass the OAuth token in the query string, as a header, or as a parameter 
in the request body when making a POST request. 

Query string example.
  
  GET /pizzas?token=AlYZ892hsKs

Header example.

  GET /pizzas
  Authorization: OAuth2 AlYZ892hsKs

Request body example.

  POST /pizzas
  token=AlYZ892hsKs&...

Note that all requests must be done using HTTPS.



= Miscellaneous 

== OAuth 2.0 options

Rest OAuth 2.0 Server allows you to personalize some options changing {oauth.yml}[https://github.com/Lelylan/rest-oauth2-server/blob/master/config/oauth.yml]

* <b>token_expires_in</b>: define the seconds after which the access token expires. 
* <b>authorization_expires_in</b>: define the seconds after which the authorization code expires. 
* <b>secure_random</b>: define the lenght of tokens, code and secret keys.
* <b>scope_separator</b>: define the separator used between different scope keys.


== OAuth 2.0 Models

Rest OAuth 2.0 Server is working on top of 5 models. They are pretty simple so if you want to have more information about
them, check the source code, which is clearly documented.

* {OauthClient}[https://github.com/Lelylan/rest-oauth2-server/blob/master/app/models/client.rb]: represents the credentials of a client application.
* {OauthToken}[https://github.com/Lelylan/rest-oauth2-server/blob/master/app/models/oauth/oauth_token.rb]: represents the token used to access user's resources.
* {OauthAuthorizarion}[https://github.com/Lelylan/rest-oauth2-server/blob/master/app/models/oauth/oauth_authorization.rb]: represents the authorization token used to exchange an access token.
* {OauthAccess}[https://github.com/Lelylan/rest-oauth2-server/blob/master/app/models/oauth/oauth_access.rb]: represents the relation between a client and a user, whenever a user grant an authorization.
* {OauthDailyRequests}[https://github.com/Lelylan/rest-oauth2-server/blob/master/app/models/oauth/oauth_daily_request.rb]: represents a daily request from the client on behalf of a specific user.


== Basic authentication system

In addition to the models above there is a basic authentication system

* {User}[https://github.com/Lelylan/rest-oauth2-server/blob/master/app/models/user.rb]: represents the basic user authentication functionalities
* {UsersController}[https://github.com/Lelylan/rest-oauth2-server/blob/master/app/controllers/users_controller.rb]: represents the user definition
* {SessionsController}[https://github.com/Lelylan/rest-oauth2-server/blob/master/app/controllers/sessions_controller.rb]: represents the session definition

This model is kept simple on purpose, but you can easily change it with the authentication system you prefer like {Authlogic}[https://github.com/binarylogic/authlogic],
{Devise}[https://github.com/plataformatec/devise] or {Warden}[https://github.com/hassox/warden]. Just remember that your user model <b>must</b> 
define an <tt>uri</tt> field, which is used as identifier on the OAuth 2.0 flows. Any help on integration is appreciated.


== Blocking system explained

One important feature lie in the ability of to block a client. Rest OAuth 2.0 server enables you two possibilities:

* <b>Client block</b> via <tt>client.block!</tt>: used to block a not safe client for all users.
* <b>User block a client</b> via <tt>access.block!</tt>: used when a user want to revoke any access to his resources to a specific client.
* <b>User block an access token</b> via <tt>token.block!</tt>: used when a user logout from the client and want to revoke the token access.

In the first two cases it is possible to unblock the client using the <tt>unblock!</tt> method.


== Testing solutions

Tests are made using {Steak}[https://github.com/cavalle/steak], {Capybara}[https://github.com/jnicklas/capybara] 
and {RSpec}[https://github.com/rspec/rspec-rails]. If you want to know more check the tests about {models}[https://github.com/Lelylan/rest-oauth2-server/tree/development/spec/models]
and {acceptance tests}[https://github.com/Lelylan/rest-oauth2-server/tree/development/spec/acceptance].



= Other OAuth2 documentation

If the way OAuth2 works is not clear, you can find great documentation on the web.

* {Oauth2 Specifications}[http://tools.ietf.org/html/draft-ietf-oauth-v2-13]
* {Google OAuth2}[http://code.google.com/apis/accounts/docs/OAuth2.html]
* {Facebook OAuth2}[http://developers.facebook.com/docs/authentication]
* {Gowalla OAuth2}[http://gowalla.com/api/docs/oauth]
* {Foursquare OAuth2}[http://developer.foursquare.com/docs/oauth.html]
* {Instagram OAuth2}[http://instagram.com/developer/auth/]



= Other OAuth2 Ruby Implementations

* {Flowtown Rack OAuth2 Server}[https://github.com/flowtown/rack-oauth2-server]
* {Nov Rack OAuth2}[https://github.com/nov/rack-oauth2]
* {ThoughWorks OAuth2 Provider}[https://github.com/ThoughtWorksStudios/oauth2_provider]
* {Freerange OAuth2 Provider}[https://github.com/freerange/oauth2-provider/blob/master/lib/oauth2/provider/models/access_token.rb]



= Contributing

Follow {MongoID guidelines}[http://mongoid.org/docs/contributing.html]


= Authors

{Andrea Reginato}[mailto:andrea.reginato@gmail.com] & 
{The Lelylan Team}[http://lelylan.com]

A special thanks to the OAuth 2.0 specification team, to the Flowtown Rack Oauth2 Server which gave the 
initial ideas of the project and to Google OAuth 2.0 specification for making them so clear to understand.



= Changelog

See {CHANGELOG}[link:blob/master/CHANGELOG.rdoc]



= License

Rest OAuth 2.0 Server is available under the MIT license.
