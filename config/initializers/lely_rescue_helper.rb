module Lelylan
  module Rescue
    module Helpers

      def bson_invalid_object_id(e)
        flash.now.alert =  "notifications.document.not_found"
        @info = { id: params[:id] }
        render "shared/html/404" and return
      end

      def json_parse_error(e)
        flash.now.alert =  "notifications.document.not_found"
        @info = { id: params[:id] }
        render "shared/html/404" and return
      end

      def mongoid_errors_invalid_type(e)
        flash.now.alert =  "notifications.document.not_found"
        @info = e.message.gsub(/ActiveSupport::HashWithIndifferentAccess/, "Hash")
        render "shared/html/404" and return
      end

    end
  end
end
