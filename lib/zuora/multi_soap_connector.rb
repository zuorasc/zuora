module Zuora
  class MultiSoapConnector < SoapConnector

    def self.configure(name, options ={})
      @configs ||= {}
      api = Zuora::Api.new
      api.config = Zuora::Config.new(options)
      @configs[name] = api
    end

    def self.use_config(name)
      # on the current instance?
      Thread.current[:zuora_config] = name
      yield
    ensure
      Thread.current[:zuora_config] = nil
    end

    def self.current_client
      @configs[Thread.current[:zuora_config]]
    end

    def current_client
      self.class.current_client
    end
  end
end
