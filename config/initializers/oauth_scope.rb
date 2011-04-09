module Oauth

  def self.normalize_scope(scope)
    scope = scope.split(" ") if scope.kind_of? String
    normalized = Scope.any_in(name: scope)
    normalized = normalized.map(&:values).flatten
    if normalized.empty?
      return scope
    else
      return scope + self.normalize_scope(normalized)
    end
  end

end
