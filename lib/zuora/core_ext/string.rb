module Zuora
  module CoreExt
    module String

      def base_name
        dup.scan(/\w+$/).first
      end unless method_defined?(:base_name)

    end
  end
end

String.send :include, Zuora::CoreExt::String

