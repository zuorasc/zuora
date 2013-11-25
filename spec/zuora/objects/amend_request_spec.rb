require 'spec_helper'

describe Zuora::Objects::AmendRequest do

  describe "most persistence methods" do
    it "are not publicly available" do
      [:update, :destroy, :where, :find].each do |meth|
        subject.public_methods.should_not include(meth)
      end
    end
  end

  describe "generating a request" do
    before do 
      subscription = FactoryGirl.build(:subscription)
      @amendment = FactoryGirl.build(:amendment)
      @amendment.subscription_id = subscription.id
      MockResponse.responds_with(:payment_method_credit_card_find_success) do
        product_rate_plans = [Zuora::Objects::ProductRatePlan.find('stub')]

        @prps = Zuora::Objects::RatePlan.new
        @prps.product_rate_plan_id = product_rate_plans[0].id
        @product_rate_plans = [@prps]
      end
    end

    it "handles applying amend failures messages" do
      MockResponse.responds_with(:amend_request_failure) do
        @amendment.subscription_id = '2c92c0f93a569878013a6778f0446b11'
        subject.amendment = @amendment
        subject.plans_and_charges = Array.new << { rate_plan: @product_rate_plans[0], charges: nil }
        amnd_resp = subject.create
        amnd_resp[:success].should == false
        amnd_resp[:errors][:message].should include('Invalid value for field SubscriptionId: 2c92c0f93a569878013a6778f0446b11')
      end
    end
  end  
end
