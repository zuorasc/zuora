require 'singleton'
require 'savon'

module Zuora

  # Configure Zuora by passing in an options hash. This must be done before
  # you can use any of the Zuora::Object models.
  # @example
  #   Zuora.configure(:username => 'USERNAME', :password => 'PASSWORD')
  # @param [Hash] configuration option hash
  # @return [Config]
  def self.configure(opts={})
    Api.instance.config = Config.new(opts)
    if Api.instance.config.sandbox
      Api.instance.sandbox!
    end
  end

  class Api
    include Singleton

    # @return [Savon::Client]
    def client
      @client ||= make_client
    end

    # @return [Zuora::Session]
    attr_accessor :session

    # @return [Zuora::Config]
    attr_accessor :config
 
    # @return Zuora::Api options
    attr_accessor :options

    # The XML that was transmited in the last request
    # @return [String]
    attr_reader :last_request

    WSDL = File.expand_path('../../../wsdl/zuora.a.38.0.wsdl', __FILE__)
    SOAP_VERSION = 2
    SANDBOX_ENDPOINT = 'https://apisandbox.zuora.com/apps/services/a/38.0'

    def wsdl
      client.instance_variable_get(:@wsdl)
    end

    # Is this an authenticated session?
    # @return [Boolean]
    def authenticated?
      self.session.try(:active?)
    end

    # Change client to sandbox url
    def sandbox!
      @client = nil
      self.class.instance.client.globals[:endpoint] = SANDBOX_ENDPOINT
    end

    # Generate an API request with the given block.  The block yields an xml
    # builder instance which can be used to build out the request as needed.
    # You can also provide the xml_body which will be used instead of the block.
    # @param [Symbol] symbol of the WSDL operation to call
    # @param [String] string xml body pass to the operation
    # @yield [Builder] xml builder instance
    # @raise [Zuora::Fault]
    def request(method, options={}, &block)
      authenticate! unless authenticated?

      if block_given?
        xml = Builder::XmlMarkup.new
        yield xml
        options[:message] = xml.target!
      end

      client.call(method, options)
    rescue Savon::SOAPFault, IOError => e
      raise Zuora::Fault.new(:message => e.message)
    end

    # Attempt to authenticate against Zuora and initialize the Zuora::Session object
    #
    # @note that the Zuora API requires username to come first in the SOAP request so
    # it is manually generated here instead of simply passing an ordered hash to the client.
    #
    # Upon failure a Zoura::Fault will be raised.
    # @raise [Zuora::Fault]
    def authenticate!
      response = client.call(:login) do
        message username: Zuora::Api.instance.config.username, password: Zuora::Api.instance.config.password
      end
      self.session = Zuora::Session.generate(response.to_hash)
      client.globals.soap_header({'env:SessionHeader' => {'ins0:Session' => self.session.try(:key) }})
    rescue Savon::SOAPFault => e
      raise Zuora::Fault.new(:message => e.message)
    end

    private

    def initialize
      @config = Config.new
    end

    def make_client
      savon_options = {
        wsdl: WSDL,
        soap_version: SOAP_VERSION,
        log: config.log || false,
        logger: config.logger,
        ssl_verify_mode: :none
      }.reject! { |k, v| v.nil? }

      Savon.client(savon_options)
    end

  end
end

