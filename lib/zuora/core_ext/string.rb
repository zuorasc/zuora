module Zuora
  module CoreExt
    module String

      def base_name
        dup.scan(/\w+$/).first
      end unless method_defined?(:base_name)

      def zuora_camelize
        if match(/__c$/)
          self.gsub("__c","").zuora_camelize + "__c"
        else
          camelize
        end
      end unless method_defined?(:zuora_camelize)

    end
  end
end

String.send :include, Zuora::CoreExt::String

