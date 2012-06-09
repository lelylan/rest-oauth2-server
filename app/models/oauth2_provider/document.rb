module Oauth2Provider
  module Document
    module Base

      def base_uri(request)
        protocol = request.protocol
        host = request.host_with_port
        name = self.class.name.underscore.pluralize.split('/').last
        id   = self.id.as_json
        uri  = protocol + host + "/oauth/" + name + "/" +  id
      end

    end
  end
end
