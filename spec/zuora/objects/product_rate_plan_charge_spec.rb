require 'spec_helper'

describe Zuora::Objects::ProductRatePlanCharge do

  describe "complex association support" do
    it "should have blank association for new object" do
      subject.product_rate_plan_charge_tiers.should == []
    end

    it "should allow adding objects to the association" do
      obj = mock('Example')
      subject.product_rate_plan_charge_tiers << obj
      subject.product_rate_plan_charge_tiers.should == [obj]
    end
  end
end
