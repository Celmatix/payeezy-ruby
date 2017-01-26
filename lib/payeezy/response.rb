module Payeezy
  class Response
    include Enumerable

    Struct.new("Token", :token_type, :token_data)
    Struct.new("Card", :type, :cardholder_name, :card_number, :exp_date)

    RESPONSE_FIELDS = [
      :correlation_id, :transaction_status, :validation_status,
      :transaction_type, :transaction_id, :transaction_tag, :method,
      :amount, :currency, :cvv2, :token, :card,
      :gateway_resp_code, :gateway_message,

      :bank_response, :gateway_response,

      :errors,

      :raw_response
    ]

    attr_accessor *RESPONSE_FIELDS

    def initialize(raw_response)
      begin
        @raw_response = JSON.parse(raw_response)
      rescue JSON::ParserError
        @parser_error = true
      end

      @errors = []

      process_response
    end

    def [](key)
      @raw_response[key]
    end

    def each(&block)
      @raw_response.each(&block)
    end

    def success?
      !parser_error? && !validation_error? && !transaction_error?
    end

    def parser_error?
      !!@parser_error
    end

    def validation_error?
      validation_status != STATUS_SUCCESS
    end

    def transaction_error?
      transaction_status != STATUS_APPROVED
    end

    def bank_error?
      return false if bank_response.nil?
      !bank_response.success?
    end

    def internal_error?
      self.is_a?(InternalErrorResponse)
    end

    private

    def process_response
      raw = @raw_response.dup
      if raw["bank_resp_code"]
        self.bank_response = Payeezy::BankResponse.new(
          raw["bank_resp_code"],
          raw["bank_message"]
        )
      end

      self.gateway_response = Payeezy::GatewayResponse.new(raw["gateway_resp_code"], raw["gateway_message"])

      raw.each do |key, value|
        case key
        when "token"
          @token = Struct::Token.new(value["token_type"], value["token_data"]["value"])
        when "Error"
          @errors = value["messages"].collect do |msg|
            Payeezy::ValidationError.new(msg["code"], msg["description"])
          end
        else
          instance_variable_set(:"@#{key.downcase}", value)
        end
      end

      @errors << gateway_response.error unless gateway_response.success?
    end
  end
end
