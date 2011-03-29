# TODO: organize this in a Lelylan::Oauth::Scope class so
# that you can give it a more modular structure

module Lelylan
  module Oauth
    module Scope

      SCOPE = %w(
        type.read type.write
        property.read property.write
        function.read function.write
        status.read status.write
      )

      MATCHES = {
        write: SCOPE,
        read: %w(type.read property.read function.read status.read),
        type: %w(type.read type.write),
        property: %w(property.read property.write),
        function: %w(function.read function.write),
        status: %w(status.read status.write)
      }

      def self.normalize(scope = [])
        normalized = scope.clone
        scope.each { |key| normalized << MATCHES[key.to_sym] }
        normalized.flatten!
        intersection = normalized & SCOPE
        return intersection
      end

    end
  end
end
