module Payeezy
  class GatewayResponse < BankResponse
    TRANSACTION_NORMAL = "00"
    def success?
      code == TRANSACTION_NORMAL
    end

    def status
      code
    end

    def error
      GatewayError.new(code, message)
    end
  end
end
