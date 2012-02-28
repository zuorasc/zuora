module Zuora
  class Session
    # @return [String] session key provided from response
    attr_accessor :key
    # @return [String] server url from response
    attr_accessor :server_url
    # @return [Time] expiration time of session
    attr_accessor :expires_at

    # Generate a Zuora::Session object from the results hash of the login procedure. Additionally,
    # the session will only be valid for 10 minutes before it expires. A newly authenticated session
    # object will be required to make further requests after this timeout.
    # @param [Hash]
    # @return [Session]
    def self.generate(result_hash)
      result = result_hash[:login_response][:result]
      new(:key => result[:session], :server_url => result[:server_url], :expires_at => Time.now + 600)
    end

    # Has the session expired?
    # @return [Boolean]
    def expired?
      expires_at <= Time.now
    end

    # Is the session active?
    # @return [Boolean]
    def active?
      !expired?
    end

    # Create a new Session instance
    def initialize(attrs={})
      attrs.each do |k,v|
        self.send("#{k}=", v)
      end
    end
  end
end
