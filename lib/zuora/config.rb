module Zuora
  class Config
    def initialize(data={})
      @data = {}
      update!(data)
    end
    def update!(data)
      data.each do |key, value|
        self[key] = value
      end
    end

    def [](key)
      @data[key.to_sym]
    end

    def []=(key, value)
      if value.kind_of?(Hash)
        @data[key.to_sym] = Config.new(value)
      else
        @data[key.to_sym] = value
      end
    end

    def method_missing(sym, *args)
      if sym.to_s =~ /(.+)=$/
        self[$1] = args.first
      else
        self[sym]
      end
    end

    def respond_to?(method_sym, include_private = false)
      if @data.keys.include?(method_sym)
        true
      else
        super
      end
    end
  end
end

