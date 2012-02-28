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

    it "should load remote associations when not a new record" do
      subject.id = 'test'
      subject.should_not be_new_record

      MockResponse.responds_with(:product_rate_plan_charge_tier_find_success) do
        subject.product_rate_plan_charge_tiers.size.should == 2
      end

      xml = Zuora::Api.instance.last_request
      xml.should have_xml('//env:Body/ins0:query/ins0:queryString').
        with_value(/select .+ from ProductRatePlanChargeTier where ProductRatePlanChargeId = 'test'/)
    end
  end

  it 'can create a product rate plan with several charge tiers' do
    MockResponse.responds_with(:product_find_success) do
      @product = Zuora::Objects::Product.find('4028e4883491c50901349d061be06550')
    end

    MockResponse.responds_with(:product_rate_plan_find_success) do
      @prp = @product.product_rate_plans.first
    end

    @prpc = Zuora::Objects::ProductRatePlanCharge.new do |c|
      c.product_rate_plan = @prp
      c.name = "Monthly Allowance"
      c.bill_cycle_type = 'DefaultFromCustomer'
      c.billing_period = "Month"
      c.billing_period_alignment = "AlignToCharge"
      c.charge_model = "Volume Pricing"
      c.charge_type = "Recurring"
      c.included_units = "10"
      c.smoothing_model = 'Rollover'
      c.uom = 'Each'
      c.trigger_event = "ServiceActivation"
    end

    # new objects should have empty association
    @prpc.product_rate_plan_charge_tiers.should == []

    tier1 = Zuora::Objects::ProductRatePlanChargeTier.new do |t|
      t.price = 0
      t.active = true
      t.starting_unit = 0
      t.ending_unit = 10
    end

    tier2 = Zuora::Objects::ProductRatePlanChargeTier.new do |t|
      t.price = 50
      t.active = true
      t.starting_unit = 11
      t.ending_unit = 20
    end

    @prpc.should_not be_valid, 'tiers are required to be valid'
    @prpc.product_rate_plan_charge_tiers << tier1
    @prpc.product_rate_plan_charge_tiers << tier2
    @prpc.should be_valid, 'tiers are required to be valid'

    MockResponse.responds_with(:product_rate_plan_charge_create_success) do
      @prpc.save.should == true
      @prpc.should_not be_new_record
    end

    xml = Zuora::Api.instance.last_request
    xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:ProductRatePlanChargeTierData')
    xml.should have_xml('//ins2:ProductRatePlanChargeTierData/ins0:ProductRatePlanChargeTier')
    xml.should have_xml('//ins0:ProductRatePlanChargeTier/ins2:Active').with_value(true)
    xml.should have_xml('//ins0:ProductRatePlanChargeTier/ins2:Price').with_value(50)
    xml.should have_xml('//ins0:ProductRatePlanChargeTier/ins2:StartingUnit').with_value(11)
    xml.should have_xml('//ins0:ProductRatePlanChargeTier/ins2:EndingUnit').with_value(20)

    MockResponse.responds_with(:product_rate_plan_charge_tier_find_success) do
      @prpct = @prpc.product_rate_plan_charge_tiers
      @prpct.size.should == 2
    end

    @prpct.map(&:new_record?).should be_none, 'complex objects should not be new records after save'

    @prpc.product_rate_plan_charge_tiers.first.price = 20
    @prpc.product_rate_plan_charge_tiers.first.price.should == 20 
  
    MockResponse.responds_with(:product_rate_plan_charge_update_success) do
      @prpc.save.should == true
    end

    xml = Zuora::Api.instance.last_request
    xml.should have_xml('//env:Body/ins0:update/ins0:zObjects/ins2:ProductRatePlanChargeTierData')
    xml.should have_xml('//env:Body/ins0:update/ins0:zObjects/ins2:Id')
    xml.should have_xml('//ins2:ProductRatePlanChargeTierData/ins0:ProductRatePlanChargeTier')
    xml.should have_xml('//ins0:ProductRatePlanChargeTier/ins2:Active').with_value(true)
    xml.should have_xml('//ins0:ProductRatePlanChargeTier/ins2:Price').with_value(20)
    xml.should_not have_xml('//ins0:ProductRatePlanChargeTier/ins0:Id')
    xml.should_not have_xml('//ins0:ProductRatePlanChargeTier/ins2:StartingUnit')
    xml.should_not have_xml('//ins0:ProductRatePlanChargeTier/ins2:EndingUnit')
    
    MockResponse.responds_with(:product_rate_plan_charge_destroy_success) do
      @prpc.destroy
    end

    xml = Zuora::Api.instance.last_request
    xml.should have_xml('//env:Body/ins0:delete/ins0:type').with_value('ProductRatePlanCharge')
    xml.should have_xml('//env:Body/ins0:delete/ins0:ids').with_value('4028e48834aa10a30134aaf7f40b3139')
  end
end
