module Lelylan
  module Document
    module Base

      #def self.included(base)
        #base.extend(ClassMethods)
      #end

      def base_uri(request)
        protocol = request.protocol
        host = request.host_with_port
        name = self.class.name.underscore.pluralize
        id   = self.id.as_json
        uri  = protocol + host + "/" + name + "/" +  id
      end

    end
  end
end
