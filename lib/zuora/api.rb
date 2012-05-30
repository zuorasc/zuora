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
    HTTPI.logger = opts[:logger]
    HTTPI.log = opts[:logger] ? true : false
    Savon.configure do |savon|
      savon.logger = opts[:logger]
      savon.log = opts[:logger] ? true : false
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

    WSDL = File.expand_path('../../../wsdl/zuora.a.38.0.wsdl', __FILE__)

    # Is this an authenticated session?
    # @return [Boolean]
    def authenticated?
      self.session.try(:active?)
    end

    # The XML that was transmited in the last request
    # @return [String]
    def last_request
      client.http.body
    end

    # Generate an API request with the given block.  The block yields an xml
    # builder instance which can be used to build out the request as needed.
    # You can also provide the xml_body which will be used instead of the block.
    # @param [Symbol] symbol of the WSDL operation to call
    # @param [String] string xml body pass to the operation
    # @yield [Builder] xml builder instance
    # @raise [Zuora::Fault]
    def request(method, xml_body=nil, &block)
      authenticate! unless authenticated?

      response = client.request(method) do
        soap.header = {'env:SessionHeader' => {'ins0:Session' => self.session.try(:key) }}
        if block_given?
          soap.body{|xml| yield xml }
        else
          soap.body = xml_body
        end
      end
    rescue Savon::SOAP::Fault, IOError => e
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
      response = client.request(:login) do
        ns = Zuora::Api.instance.client.soap.namespace_by_uri('http://api.zuora.com/')
        soap.body = "<#{ns}:username>#{config.username}</#{ns}:username><#{ns}:password>#{config.password}</#{ns}:password>"
      end
      self.session = Zuora::Session.generate(response.to_hash)
    rescue Savon::SOAP::Fault => e
      raise Zuora::Fault.new(:message => e.message)
    end

    private

    def initialize
      Savon.configure do |savon|
        savon.soap_version = 2
      end
    end

    def make_client
      Savon::Client.new do
        wsdl.document = (defined?(ZUORA_WSDL) && ZUORA_WSDL) || WSDL
        http.auth.ssl.verify_mode = :none
      end
    end

  end
end

