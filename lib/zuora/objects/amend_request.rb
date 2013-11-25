module Zuora::Objects
  class AmendRequest < Base

    attr_accessor :amendment
    attr_accessor :plans_and_charges

    store_accessors :amend_options
    store_accessors :preview_options

    attr_accessor :validation_errors

    validate do |request|
      self.validation_errors = Array.new
      self.validation_errors << request.must_be_present(:amendment)
      self.validation_errors << request.must_be_present(:plans_and_charges) unless amendment.type == "TermsAndConditions" || amendment.type == "Renewal"
    end

    def must_be_present(ref)
      obj = self.send(ref)
      return errors[ref] << "#{ref} must be provided" if obj.nil?
    end

    # Generate an amend request
    def create
      return validation_errors unless valid?
      result = Zuora::Api.instance.request(:amend) do |xml|
        xml.__send__(zns, :requests) do |r|
          r.__send__(zns, :Amendments) do |a|
            generate_amendment a
            generate_rate_plan_data a
          end

          r.__send__(zns, :AmendOptions) do |so|
            generate_amend_options(so)
          end unless amend_options.blank?

          r.__send__(zns, :PreviewOptions) do |so|
            generate_preview_options(so)
          end unless preview_options.blank?

        end
      end
      apply_response(result.to_hash, :amend_response)
    end

    protected

    def apply_response(response_hash, type)
      result = response_hash[type][:results]
      
    end

    def generate_amend_options(builder)
      amend_options.each do |k,v|
        builder.__send__(zns, k.to_s.zuora_camelize.to_sym, v)
      end
    end
    
    def generate_preview_options(builder)
      preview_options.each do |k,v|
        builder.__send__(zns, k.to_s.zuora_camelize.to_sym, v)
      end
    end

    def generate_amendment(builder)        
      amendment.to_hash.each do |k,v|
        if k.to_s != 'rate_plan_data'
          builder.__send__(ons, k.to_s.zuora_camelize.to_sym, v) unless v.nil?
        end 
      end      
    end

    def generate_rate_plan_data(builder)

      self.plans_and_charges.each do |pandc|
        rate_plan = pandc[:rate_plan]
        charges = pandc[:charges]

        builder.__send__(ons, :RatePlanData) do |rpd|
          rpd.__send__(zns, :RatePlan) do |rp|
            rate_plan.to_hash.each do |k,v|
              rp.__send__(ons, k.to_s.zuora_camelize.to_sym, v) unless v.nil?
            end
          end
          charges.each do |charge|
            rpd.__send__(zns, :RatePlanChargeData) do |rpcd|
              rpcd.__send__(zns, :RatePlanCharge) do |rpc|
                rpc.__send__(ons, :ProductRatePlanChargeId, charge.product_rate_plan_charge_id)
                rpc.__send__(ons, :Quantity, charge.quantity)
                rpc.__send__(ons, :Price, charge.price) unless charge.price.nil?
              end
            end
          end unless charges == nil
        end
      end
    end

    # TODO: Restructute an intermediate class that includes
    # persistence only within ZObject models.
    # These methods are not relevant, but defined in Base
    def find ; end
    def where ; end
    def update ; end
    def destroy ; end
    def save ; end
  end
end