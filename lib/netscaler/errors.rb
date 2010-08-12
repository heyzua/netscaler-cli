
module Netscaler
  Error = Class.new(RuntimeError)

  ConfigurationError = Class.new(Netscaler::Error)
  TransactionError = Class.new(Netscaler::Error)
end
