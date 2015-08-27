module Zuora::Objects
  class AmendRequest < Base
    attr_accessor :amendment

    store_accessors :amend_options

    validate do |request|
      request.must_have_usable(:amendment)
    end

    # used to validate nested objects
    def must_have_usable(ref)
      obj = self.send(ref)
      return errors[ref] << "must be provided" if obj.blank?
      obj = obj.is_a?(Array) ? obj : [obj]
      obj.each do |object|
        if object.new_record? || object.changed?
          errors[ref] << "is invalid" unless object.valid?
        end
      end
    end

    # Generate and request an AmendRequest xml object
    def update
      result = Zuora::Api.instance.request(:amend) do |xml|
        xml.__send__(zns, :requests) do |r|
          s.__send__(zns, :Amendments) do |a|
            generate_object(a, amendment)
          end

          s.__send__(zns, :AmendOptions) do |a|
            generate_amend_options(a)
          end unless amend_options.blank?
        end
      end

      apply_response(result.to_hash, :amend_response)
    end

    protected

    def apply_response(response_hash, type)
      result = response_hash[type][:result]
      if result[:success]
        amendment.clear_changed_attributes!
        @previously_changed = changes
        @changed_attributes.clear
      else
        self.errors.add(:base, result[:errors][:message])
      end
      return result
    end

    def generate_object(builder, object)
      if object.new_record?
        object.to_hash.each do |k,v|
          builder.__send__(ons, k.to_s.zuora_camelize.to_sym, v) unless v.nil?
        end
      else
        builder.__send__(ons, :Id, object.id)
      end
    end

    def generate_amend_options(builder)
      amend_options.each do |k,v|
        builder.__send__(zns, k.to_s.zuora_camelize.to_sym, v)
      end

      builder.__send__(zns, :ExternalPaymentOptions) do |epo|
        generate_external_payment_options(epo)
      end unless amend_options[:external_payment_options].blank?

      # TODO: Implement missing InvoiceProcessingOptions container
    end

    def generate_external_payment_options(builder)
      external_payment_options.each do |k,v|
        builder.__send__(zns, k.to_s.zuora_camelize.to_sym, v)
      end
    end

    # TODO: Restructute an intermediate class that includes
    # persistence only within ZObject models.
    # These methods are not relevant, but defined in Base
    def find ; end
    def where ; end
    def create ; end
    def destroy ; end
    def save ; end
  end
end

