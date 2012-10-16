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
        @product_rate_plans = [Zuora::Objects::ProductRatePlan.find('stub')]
      end
    end

    it "provides properly formatted xml when using existing objects" do
      MockResponse.responds_with(:amend_request_success) do
        subject.amendment = @amendment
        subject.plans_and_charges = Array.new << { rate_plan: @product_rate_plans[0], charges: nil }
        amnd_resp = subject.create
        amnd_resp[:success].should == true
      end

      xml = Zuora::Api.instance.last_request
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{zns}:Type").
        with_value('NewProduct')
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{zns}:Name").
        with_value('Example Amendment 1')
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:RatePlanData/#{ons}:RatePlan/#{ons}:ProductRatePlanId").
        with_value('4028e48834aa10a30134c50f40901ea7')
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

    it "supports amend options" do
      MockResponse.responds_with(:amend_request_success) do
        subject.amendment = @amendment
        subject.plans_and_charges = Array.new << { rate_plan: @product_rate_plans[0], charges: nil }
        subject.amend_options = {:generate_invoice => true, :process_payments => true}
        amnd_resp = subject.create
        amnd_resp[:success].should == true
      end

      xml = Zuora::Api.instance.last_request
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:AmendOptions/#{zns}:GenerateInvoice").
        with_value(true)
    end

    it "supports preview options" do
      MockResponse.responds_with(:amend_request_success) do
        subject.amendment = @amendment
        subject.plans_and_charges = Array.new << { rate_plan: @product_rate_plans[0], charges: nil }
        subject.preview_options = { enable_preview_mode: true, number_of_periods: 1 }
        amnd_resp = subject.create
        amnd_resp[:success].should == true
      end

      xml = Zuora::Api.instance.last_request
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:PreviewOptions/#{zns}:EnablePreviewMode").
        with_value(true)
    end

    it "supports multiple rate plans with multiple charges" do
      MockResponse.responds_with(:amend_request_success) do

        rpc = Zuora::Objects::RatePlanCharge.new
        rpc.quantity = 12
        rpc.product_rate_plan_charge_id = '123'

        rp = Zuora::Objects::ProductRatePlan.new
        rp.id = @product_rate_plans[0].id

        pandc = Array.new
        pandc << {rate_plan: rp, charges: [rpc]}
        pandc << {rate_plan: rp, charges: [rpc]}
        subject.amendment = @amendment
        subject.plans_and_charges = pandc
        subject.should be_valid
        sub_resp = subject.create
        sub_resp[:success].should == true
      end
      xml = Zuora::Api.instance.last_request
      xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:RatePlanData")
    end

  end  
end
