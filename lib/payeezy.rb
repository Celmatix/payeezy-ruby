module Payeezy
  STATUS_SUCCESS  = "success"
  STATUS_APPROVED = "approved"
end

require 'payeezy/version'

require 'payeezy/actions'
require 'payeezy/response'
require 'payeezy/transactions'
require 'payeezy/bank_response'
require 'payeezy/gateway_response'
require 'payeezy/internal_error_response'
require 'payeezy/errors'
