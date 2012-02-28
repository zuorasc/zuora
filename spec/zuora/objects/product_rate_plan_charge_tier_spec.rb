require 'spec_helper'

describe Zuora::Objects::ProductRatePlanChargeTier do
  describe "attribute conversion support" do
    it "has properly casted attributes" do
      MockResponse.responds_with(:product_rate_plan_charge_tier_find_success) do
        tier = Zuora::Objects::ProductRatePlanChargeTier.find('whatever')
        tier.price.should == 0
      end
    end
  end
end

