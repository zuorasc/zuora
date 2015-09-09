require 'spec_helper'
require 'date'

describe Zuora::Objects::AmendRequest do
  describe "most persistence methods" do
    it "are not publicly available" do
      [:destroy, :where, :find, :update].each do |meth|
        subject.public_methods.should_not include(meth)
      end
    end
  end

  let(:amendment) {
    Zuora::Objects::Amendment.new(
      subscription_id: '2c92c0f84f6deb9b014f718d29bb35b1',
      name: 'Example Amendment',
      status: 'Completed',
      type: 'Renewal',
      contract_effective_date: Date.today
    )
  }

  let(:external_payment_options) {
    {
      amount: 5.to_f,
      effective_date: DateTime.now.strftime("%Y-%m-%d"),
      payment_method_id: '23423rwafeffsefsfse'
    }
  }

  let(:amend_options) {
    {
      generate_invoice: false,
      process_payments: false
    }
  }

  describe "validations" do
    describe "#must_have_usable" do
      context "on amendment" do
        before do
          subject.amendment = amendment
        end

        it "should contain errors when the amendment is not valid" do
          amendment.should_receive(:valid?).and_return(false)
          subject.must_have_usable(:amendment)
          subject.errors[:amendment].should include("is invalid")
        end

        it "should not add errors when the amendment is valid" do
          amendment.should_receive(:valid?).and_return(true)
          subject.must_have_usable(:amendment)
          subject.errors[:amendment].should be_blank
        end
      end
    end
  end

  describe "generating a request" do
    before do
      subject.amendment = amendment
    end
    describe '#create' do
      it 'should include the amendment' do
        MockResponse.responds_with(:amend_request_success) do
          subject.create
        end

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments")
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:SubscriptionId").with_value(amendment.subscription_id)
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:Type").with_value(amendment.type)
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:Name").with_value(amendment.name)
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:Status").with_value(amendment.status)
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:ContractEffectiveDate").with_value(amendment.contract_effective_date.strftime('%F'))
      end
      it 'should supply amend_options' do
        MockResponse.responds_with(:amend_request_success) do
          subject.amend_options = amend_options
          subject.create
        end

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:AmendOptions/#{zns}:GenerateInvoice").with_value(amend_options[:generate_invoice])
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:AmendOptions/#{zns}:ProcessPayments").with_value(amend_options[:process_payments])
      end
      it 'should supply external_payment_options' do
        MockResponse.responds_with(:amend_request_success) do
          subject.external_payment_options = external_payment_options
          subject.create
        end

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:AmendOptions/#{zns}:ExternalPaymentOptions")
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:AmendOptions/#{zns}:ExternalPaymentOptions/#{zns}:Amount").with_value(external_payment_options[:amount])
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:AmendOptions/#{zns}:ExternalPaymentOptions/#{zns}:EffectiveDate").with_value(external_payment_options[:effective_date])
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:AmendOptions/#{zns}:ExternalPaymentOptions/#{zns}:PaymentMethodId").with_value(external_payment_options[:payment_method_id])
      end
      it 'should add the rate_plan_data complex type when defined' do
        MockResponse.responds_with(:amend_request_success) do
          rate_plan = Zuora::Objects::RatePlan.new(
            product_rate_plan_id: '2c92c0f84f6deb9b014f718d29bb35b1'
          )
          rate_plan_data = Zuora::Objects::RatePlanData.new
          rate_plan_data.rate_plan = rate_plan

          subject.amendment.rate_plan_data = rate_plan_data
          subject.create
        end

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments")
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:RatePlanData")
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:RatePlanData/#{ons}:RatePlan")
        xml.should have_xml("//env:Body/#{zns}:amend/#{zns}:requests/#{zns}:Amendments/#{ons}:RatePlanData/#{ons}:RatePlan/#{zns}:ProductRatePlanId").with_value(
            subject.amendment.rate_plan_data.rate_plan.product_rate_plan_id
          )
      end
    end
  end

  describe 'response' do
    before do
      subject.amendment = amendment
    end
    it 'reports an error on a failed response' do
      MockResponse.responds_with(:amend_request_failure) do
        subject.should be_valid
        resp = subject.create
        resp[:success].should == false
        subject.errors[:base].should include("Invalid value for field SubscriptionId: #{amendment.subscription_id}")
      end
    end
  end
end
