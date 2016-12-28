module Zuora
  module CoreExt
    module String

      def base_name
        dup.scan(/\w+$/).first
      end unless method_defined?(:base_name)

      def zuora_camelize
        self.include?('__c') ? self.chomp('__c').camelize + '__c' : self.camelize
      end

    end
  end
end

String.send :include, Zuora::CoreExt::String
