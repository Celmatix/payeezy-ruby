module Payeezy
  class Error < Struct
  end

  class ValidationError < Error.new(:code, :description)
  end

  class BankError < Error.new(:code, :description)
  end

  class GatewayError < Error.new(:code, :description)
  end

  class InternalError < Error.new(:err)
    def err_code
      case err
      when SocketError
        "SE"
      when JSON::ParserError
        "JPE"
      else
        "UNK"
      end
    end

    def code
      "internal_error_#{err_code}"
    end

    def description
      "There was an internal error, error code '#{err_code}'"
    end
  end
end
