module Zuora::Objects
  class SubscribeRequest < Base
    attr_accessor :account
    attr_accessor :subscription
    attr_accessor :bill_to_contact
    attr_accessor :payment_method
    attr_accessor :sold_to_contact
    attr_accessor :product_rate_plans

    store_accessors :subscribe_options

    validate do |request|
      request.must_have_usable(:account)
      request.must_have_usable(:payment_method)
      request.must_have_usable(:bill_to_contact)
      request.must_have_usable(:product_rate_plans)
      request.must_have_new(:subscription)
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
      return errors[ref] << "must be provided" if obj.blank?
      obj = obj.is_a?(Array) ? obj : [obj]
      obj.each do |object|
        if object.new_record? || object.changed?
          errors[ref] << "is invalid" unless object.valid?
        end
      end
    end

    # Generate a subscription request
    def create
      return false unless valid?
      result = Zuora::Api.instance.request(:subscribe) do |xml|
        xml.__send__(zns, :subscribes) do |s|
          s.__send__(zns, :Account) do |a|
            generate_object(a, account)
          end

          s.__send__(zns, :SubscribeOptions) do |so|
            generate_subscribe_options(so)
          end unless subscribe_options.blank?

          s.__send__(zns, :PaymentMethod) do |pm|
            generate_object(pm, payment_method)
          end

          s.__send__(zns, :BillToContact) do |btc|
            generate_object(btc, bill_to_contact)
          end

          s.__send__(zns, :SoldToContact) do |btc|
            generate_object(btc, sold_to_contact)
          end unless sold_to_contact.nil?

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

    def generate_object(builder, object)
      if object.new_record?
        object.to_hash.each do |k,v|
          builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
        end
      else
        builder.__send__(ons, :Id, object.id)
      end
    end

    def generate_subscription(builder)
      subscription.to_hash.each do |k,v|
        builder.__send__(ons, k.to_s.camelize.to_sym, v) unless v.nil?
      end
    end

    def generate_subscribe_options(builder)
      subscribe_options.each do |k,v|
        builder.__send__(ons, k.to_s.camelize.to_sym, v)
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

