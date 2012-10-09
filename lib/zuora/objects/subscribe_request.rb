module Zuora::Objects
  class SubscribeRequest < Base
    attr_accessor :account
    attr_accessor :subscription
    attr_accessor :bill_to_contact
    attr_accessor :payment_method
    attr_accessor :sold_to_contact
    attr_accessor :product_rate_plans

    attr_accessor :validation_errors

    store_accessors :subscribe_options
    store_accessors :preview_options

    
    validate do |request|
      self.validation_errors = Array.new
      self.validation_errors << request.must_have_usable(:account)
      #request.must_have_usable(:payment_method) if :preview_options["enable_preview_mode"] != true
      #request.must_have_usable(:bill_to_contact)
      #request.must_have_usable(:product_rate_plans)
      self.validation_errors << request.must_have_new(:subscription)
    end

    # used to validate nested objects
    def must_have_new(ref)
      obj = self.send(ref)
      return errors[ref] << "must be provided" if obj.nil?
      return errors[ref] << "must be new" unless obj.new_record?
      must_have_usable(ref)
    end

    # used to validate nested objects
    def must_have_usable(ref)
      obj = self.send(ref)
      return errors[ref] << "must be provided" if obj.nil?
      obj = obj.is_a?(Array) ? obj : [obj]
      obj.each do |object|
        if object.new_record? || object.changed?
          errors[ref] << "is invalid" unless object.valid?
        end
      end
      return errors
    end

    # Generate a subscription request
    def create
      return false unless valid?
      result = Zuora::Api.instance.request(:subscribe) do |xml|
        xml.__send__(zns, :subscribes) do |s|
          s.__send__(zns, :Account) do |a|
            generate_account(a)
          end

          s.__send__(zns, :PaymentMethod) do |pm|
            generate_payment_method(pm)
          end unless payment_method.nil?

          s.__send__(zns, :BillToContact) do |btc|
            generate_bill_to_contact(btc)
          end

          s.__send__(zns, :SoldToContact) do |btc|
            generate_sold_to_contact(btc)
          end unless sold_to_contact.nil?

          s.__send__(zns, :PreviewOptions) do |so|
            generate_preview_options(so)
          end unless preview_options.blank?

          s.__send__(zns, :SubscribeOptions) do |so|
            generate_subscribe_options(so)
          end unless subscribe_options.blank?

          s.__send__(zns, :SubscriptionData) do |sd|
            sd.__send__(zns, :Subscription) do |sub|
              generate_subscription(sub)
            end

            product_rate_plans.each do |product_rate_plan|
              sd.__send__(zns, :RatePlanData) do |rpd|
                rpd.__send__(zns, :RatePlan) do |rp|
                  rp.__send__(ons, :ProductRatePlanId, product_rate_plan.id)
                end
              end
            end
          end
        end
      end
      apply_response(result.to_hash, :subscribe_response)
    end

    # method to support backward compatibility of a single
    # product_rate_plan
    def product_rate_plan=(rate_plan_object)
      self.product_rate_plans = [rate_plan_object]
    end

    protected

    def apply_response(response_hash, type)
      result = response_hash[type][:result]
      if result[:success]
        subscription.id = result[:subscription_id]
        subscription.clear_changed_attributes!
        @previously_changed = changes
        @changed_attributes.clear
        return true
      else
        self.errors.add(:base, result[:errors][:message])
        return false
      end
    end

    def generate_bill_to_contact(builder)
      if bill_to_contact.new_record?
        bill_to_contact.to_hash.each do |k,v|
          builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
        end
      else
        builder.__send__(ons, :Id, bill_to_contact.id)
      end
    end

    def generate_sold_to_contact(builder)
      if sold_to_contact.new_record?
        sold_to_contact.to_hash.each do |k,v|
          builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
        end
      else
        builder.__send__(ons, :Id, sold_to_contact.id)
      end
    end

    def generate_account(builder)
      if account.new_record?
        account.to_hash.each do |k,v|
          builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
        end
      else
        builder.__send__(ons, :Id, account.id)
      end
    end

    def generate_payment_method(builder)
      if payment_method.new_record?
        payment_method.to_hash.each do |k,v|
          builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
        end
      else
        builder.__send__(ons, :Id, payment_method.id)
      end
    end

    def generate_subscription(builder)
      subscription.to_hash.each do |k,v|
        builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
      end
    end

    def generate_subscribe_options(builder)
      subscribe_options.each do |k,v|
        builder.__send__(zns, k.to_s.camelize.to_sym, v)
      end
    end
    
    def generate_preview_options(builder)
      preview_options.each do |k,v|
        builder.__send__(zns, k.to_s.zuora_camelize.to_sym, v)
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