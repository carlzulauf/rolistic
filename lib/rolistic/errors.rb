module Rolistic
  class Error < StandardError; end

  # Raised when the role/trait DSL is used incorrectly
  class DefinitionError < Error; end
end
