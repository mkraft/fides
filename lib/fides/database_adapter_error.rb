module Fides
  class DatabaseAdapterError < StandardError
    def initialize(adapter)
      super("Fides doesn't work with the #{adapter} database adapter.")
    end
  end
end