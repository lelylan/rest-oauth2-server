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

    module ActiveRecordHelp
      def scope
        @scope_array ||= JSON.parse(self.scope_json)
      end
      def scope_values
        @scope_values_array ||= JSON.parse(self.scope_values_json)
      end
      def values
        @values_array ||= JSON.parse(self.values_json)
      end
      def scope=(scope_array)
        @scope_array = scope_array
      end
      def scope_values=(scope_values_array)
        @scope_values_array = scope_values_array
      end
      def values=(values_array)
        @values_array = values_array
      end
      private
      def sync_scope_json
        potential_scope_json = @scope_array.to_json
        self.scope_json = potential_scope_json unless potential_scope_json == self.scope_json
      end
      def sync_scope_values_json
        potential_scope_values_json = @scope_values_array.to_json
        self.scope_values_json = potential_scope_values_json unless potential_scope_values_json == self.scope_values_json
      end
      def sync_values_json
        potential_values_json = @values_array.to_json
        self.values_json = potential_values_json unless potential_values_json == self.values_json
      end
    end
  end
end
