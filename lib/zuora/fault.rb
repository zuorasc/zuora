module Zuora
  class Fault < StandardError
    attr_accessor :string, :code, :message

    alias_method :to_s, :message

    def initialize(opts={})
      opts.each do |k,v|
        self.send("#{k}=", v)
      end
    end
  end
end
