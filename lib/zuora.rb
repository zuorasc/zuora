require 'savon'
require 'active_model'
require 'active_support/core_ext'

module Zuora
  require 'zuora/core_ext/string'
  require 'zuora/version'
  require 'zuora/config'
  require 'zuora/fault'
  require 'zuora/session'
  require 'zuora/api'
  require 'zuora/validations'
  require 'zuora/associations'
  require 'zuora/attributes'
  require 'zuora/objects'
  require 'zuora/soap_connector'

  autoload :MultiSoapConnector, 'zuora/multi_soap_connector'
end
