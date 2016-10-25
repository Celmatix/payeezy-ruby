module Payeezy
  class InternalErrorResponse < Response

    attr_reader :errors

    def initialize(error)
      @errors = [Payeezy::InternalError.new(error)]
    end

    def success?
      false
    end
  end
end
