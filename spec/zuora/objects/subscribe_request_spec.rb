require 'spec_helper'

describe Zuora::Objects::SubscribeRequest do

  describe "most persistence methods" do
    it "are not publicly available" do
      [:update, :destroy, :where, :find].each do |meth|
        subject.public_methods.should_not include(meth)
      end
    end
  end

  describe "#product_rate_plan=" do
    it "should assign product_rate_plans as an array containing the object" do
      MockResponse.responds_with(:payment_method_credit_card_find_success) do
        @product_rate_plan = Zuora::Objects::ProductRatePlan.find('stub')
      end
      request = Zuora::Objects::SubscribeRequest.new
      request.product_rate_plan = @product_rate_plan
      request.product_rate_plans.should eql [@product_rate_plan]
    end
  end

  describe "validations" do
    describe "#must_have_usable" do
      context "on account (being a reasonable representation of non-array objects)" do
        before do
          @account = Zuora::Objects::Account.new
          @request = Zuora::Objects::SubscribeRequest.new(:account => @account)
        end

        it "should add errors when there are problems with account" do
          @account.should_receive(:valid?).and_return(false)
          @request.must_have_usable(:account)
          @request.errors[:account].should include("is invalid")
        end

        it "should not add errors when there are no problems with account" do
          @account.should_receive(:valid?).and_return(true)
          @request.must_have_usable(:account)
          @request.errors[:account].should be_blank
        end
      end

      context "on product_rate_plans (being an array pbject)" do
        before do
          @rate_plan1 = Zuora::Objects::ProductRatePlan.new
          @rate_plan2 = Zuora::Objects::ProductRatePlan.new
          @request = Zuora::Objects::SubscribeRequest.new(:product_rate_plans => [@rate_plan1, @rate_plan2])
        end

        it "should add errors when there are no rate plans" do
          @request.product_rate_plans = nil
          @request.must_have_usable(:product_rate_plans)
          @request.errors[:product_rate_plans].should include("must be provided")
        end

        it "should add errors when there are problems with the first rate plan" do
          @rate_plan1.should_receive(:valid?).and_return(false)
          @rate_plan2.should_receive(:valid?).and_return(true)
          @request.must_have_usable(:product_rate_plans)
          @request.errors[:product_rate_plans].should include("is invalid")
        end

        it "should add errors when there are problems with the second rate plan" do
          @rate_plan1.should_receive(:valid?).and_return(true)
          @rate_plan2.should_receive(:valid?).and_return(false)
          @request.must_have_usable(:product_rate_plans)
          @request.errors[:product_rate_plans].should include("is invalid")
        end

        it "should not add errors when there are no problems with the rate plans" do
          @rate_plan1.should_receive(:valid?).and_return(true)
          @rate_plan2.should_receive(:valid?).and_return(true)
          @request.must_have_usable(:product_rate_plans)
          @request.errors[:product_rate_plans].should be_blank
        end
      end
    end
  end

  describe "generating a request" do
    before do
      MockResponse.responds_with(:account_find_success) do
        @account = subject.account = Zuora::Objects::Account.find('stub')
      end

      MockResponse.responds_with(:contact_find_success) do
        subject.bill_to_contact = Zuora::Objects::Contact.find('stub')
      end

      MockResponse.responds_with(:payment_method_credit_card_find_success) do
        subject.payment_method = Zuora::Objects::PaymentMethod.find('stub')
      end

      MockResponse.responds_with(:payment_method_credit_card_find_success) do
        subject.product_rate_plans = [Zuora::Objects::ProductRatePlan.find('stub')]
      end

      subject.subscription = FactoryGirl.build(:subscription)
    end

    it "provides properly formatted xml when using existing objects" do
      MockResponse.responds_with(:subscribe_request_success) do
        subject.should be_valid
        sub_resp = subject.create
        sub_resp[:success].should == true
      end

      xml = Zuora::Api.instance.last_request
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:Account/#{ons}:Id").
        with_value('4028e488348752ce0134876a25867cb2')
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:PaymentMethod/#{ons}:Id").
        with_value('4028e48834aa10a30134c50f40901ea7')
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:BillToContact/#{ons}:Id").
        with_value('4028e4873491cc770134972e75746e4c')
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:SubscriptionData/#{zns}:Subscription")
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:SubscriptionData/#{zns}:RatePlanData/#{zns}:RatePlan/#{ons}:ProductRatePlanId").
        with_value('4028e48834aa10a30134c50f40901ea7')
      xml.should_not have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{ons}:SubscribeOptions")
    end

    it "provides full account info when new object" do
      subject.account = FactoryGirl.build(:account)

      MockResponse.responds_with(:subscribe_request_success) do
        subject.should be_valid
        sub_resp = subject.create
        sub_resp[:success].should == true
      end

      xml = Zuora::Api.instance.last_request
      xml.should_not have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:Account/#{ons}:Id")
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:Account/#{ons}:Name")
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:Account/#{ons}:Status")
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:Account/#{ons}:Currency")
    end

    it "provides full bill_to_contact info when new object" do
      subject.bill_to_contact = FactoryGirl.build(:contact, :account => @account)

      MockResponse.responds_with(:subscribe_request_success) do
        subject.should be_valid
        sub_resp = subject.create
        sub_resp[:success].should == true
      end

      xml = Zuora::Api.instance.last_request
      xml.should_not have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:BillToContact/#{ons}:Id")
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:BillToContact/#{ons}:FirstName")
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:BillToContact/#{ons}:LastName")
    end

    it "provides full payment_method info when new object" do
      subject.payment_method = FactoryGirl.build(:payment_method_ach, :account => @account, :ach_account_name => 'Testing')

      MockResponse.responds_with(:subscribe_request_success) do
        subject.should be_valid
        sub_resp = subject.create
        sub_resp[:success].should == true
      end

      xml = Zuora::Api.instance.last_request
      xml.should_not have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:PaymentMethod/#{ons}:Id")
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:PaymentMethod/#{ons}:Type").
        with_value('ACH')
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:PaymentMethod/#{ons}:AchAccountName").
        with_value('Testing')
    end

    it "handles applying subscribe failures messages" do
      MockResponse.responds_with(:subscribe_request_failure) do
        subject.should be_valid
        sub_resp = subject.create
        sub_resp[:success].should == false
        subject.errors[:base].should include('Initial Term should be greater than zero')
      end
    end

    it "supports subscription options" do
      MockResponse.responds_with(:subscribe_request_success) do
        subject.subscribe_options = {:generate_invoice => true, :process_payments => true}
        subject.should be_valid
        sub_resp = subject.create
        sub_resp[:success].should == true
      end

      xml = Zuora::Api.instance.last_request
      xml.should have_xml("//env:Body/#{zns}:subscribe/#{zns}:subscribes/#{zns}:SubscribeOptions/#{zns}:GenerateInvoice").
        with_value(true)
    end

    it "applies valid response data to the proper nested objects and resets dirty" do
      MockResponse.responds_with(:subscribe_request_success) do
        subject.should be_valid
        sub_resp = subject.create
        sub_resp[:success].should == true
        subject.subscription.should_not be_changed
        subject.subscription.should_not be_new_record
      end
    end
  end
end
