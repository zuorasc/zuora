module Zuora::Objects
  class SubscribeRequest < Base
    attr_accessor :account
    attr_accessor :subscription
    attr_accessor :bill_to_contact
    attr_accessor :payment_method
    attr_accessor :sold_to_contact
    attr_accessor :product_rate_plan

    fattr :subscribe_options => {}

    validate do |request|
      request.must_have_usable(:account)
      request.must_have_usable(:payment_method)
      request.must_have_usable(:bill_to_contact)
      request.must_have_usable(:product_rate_plan)
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
      return errors[ref] << "must be provided" if obj.nil?
      if obj.new_record? || obj.changed?
        errors[ref] << "is invalid" unless obj.valid?
      end
    end

    # Generate a subscription request
    def create
      return false unless valid?
      result = Zuora::Api.instance.request(:subscribe) do |xml|
        xml.ins0 :subscribes do |s|
          s.ins0 :Account do |a|
            generate_account(a)
          end

          s.ins0 :SubscribeOptions do |so|
            generate_subscribe_options(so)
          end unless subscribe_options.blank?

          s.ins0 :PaymentMethod do |pm|
            generate_payment_method(pm)
          end

          s.ins0 :BillToContact do |btc|
            generate_bill_to_contact(btc)
          end

          s.ins0 :SoldToContact do |btc|
            generate_sold_to_contact(btc)
          end unless sold_to_contact.nil?

          s.ins0 :SubscriptionData do |sd|
            sd.ins0 :Subscription do |sub|
              generate_subscription(sub)
            end

            sd.ins0 :RatePlanData do |rpd|
              rpd.ins0 :RatePlan do |rp|
                rp.ins2 :ProductRatePlanId, product_rate_plan.id
              end
            end
          end
        end
      end
      apply_response(result.to_hash, :subscribe_response)
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
          builder.ins2 k.to_s.camelize.to_sym, v unless v.nil?
        end
      else
        builder.ins2 :Id, bill_to_contact.id
      end
    end

    def generate_sold_to_contact(builder)
      if sold_to_contact.new_record?
        sold_to_contact.to_hash.each do |k,v|
          builder.ins2 k.to_s.camelize.to_sym, v unless v.nil?
        end
      else
        builder.ins2 :Id, sold_to_contact.id
      end
    end

    def generate_account(builder)
      if account.new_record?
        account.to_hash.each do |k,v|
          builder.ins2 k.to_s.camelize.to_sym, v unless v.nil?
        end
      else
        builder.ins2 :Id, account.id
      end
    end

    def generate_payment_method(builder)
      if payment_method.new_record?
        payment_method.to_hash.each do |k,v|
          builder.ins2 k.to_s.camelize.to_sym, v unless v.nil?
        end
      else
        builder.ins2 :Id, payment_method.id
      end
    end

    def generate_subscription(builder)
      subscription.to_hash.each do |k,v|
        builder.ins2 k.to_s.camelize.to_sym, v unless v.nil?
      end
    end

    def generate_subscribe_options(builder)
      subscribe_options.each do |k,v|
        builder.ins2 k.to_s.camelize.to_sym, v
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

