module Lelylan
  module Rescue
    module Helpers

      def bson_invalid_object_id(e)
        redirect_to root_path, alert: "Resource not found."
      end

      def json_parse_error(e)
        redirect_to root_path, alert: "Json not valid"
      end

      def mongoid_errors_invalid_type(e)
        redirect_to root_path, alert: "Json values is not an array"
      end

    end
  end
end
