require 'spec_helper'

describe Zuora::Objects::PaymentMethod do
  before :each do
    @account = mock(Zuora::Objects::Account, :id => 1)
  end

  describe "Type helpers" do
    it "supports credit_card?" do
      FactoryGirl.build(:payment_method_credit_card).should be_credit_card
    end

    it "supports ach?" do
      FactoryGirl.build(:payment_method_ach).should be_ach
    end

    it "supports paypal?" do
      FactoryGirl.build(:payment_method_paypal).should be_paypal
    end

    it "supports debit_card?" do
      FactoryGirl.build(:payment_method_debit_card).should be_debit_card
    end

    it "supports card?" do
      FactoryGirl.build(:payment_method_credit_card).should be_card
      FactoryGirl.build(:payment_method_debit_card).should be_card
    end
  end

  describe "write only attributes" do
    ach = FactoryGirl.build(:payment_method_ach)
    ach.write_only_attributes.should == [:ach_account_number, :credit_card_number,
      :credit_card_security_code, :gateway_option_data, :skip_validation]
  end

  describe "validations" do
    describe "credit_card_expiration_year" do
      let(:payment_method) {Zuora::Objects::PaymentMethod.new(:type => "CreditCard")}
      it "should allow this year" do
        payment_method.credit_card_expiration_year = Time.now.year
        payment_method.valid?
        payment_method.errors[:credit_card_expiration_year].should_not include("must be greater than or equal to #{Time.now.year}")
      end

      it "should not allow last year" do
        payment_method.credit_card_expiration_year = (Time.now - 1.year).year
        payment_method.valid?
        payment_method.errors[:credit_card_expiration_year].should include("must be greater than or equal to #{Time.now.year}")
      end

      it "should allow next year" do
        payment_method.credit_card_expiration_year = (Time.now + 1.year).year
        payment_method.valid?
        payment_method.errors[:credit_card_expiration_year].should_not include("must be greater than or equal to #{Time.now.year}")
      end
    end
  end

  describe "Credit Card" do
    it "generates proper request xml" do
      MockResponse.responds_with(:payment_method_credit_card_create_success) do

        FactoryGirl.create(:payment_method_credit_card, :account => @account)

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:Type").
          with_value('CreditCard')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:CreditCardAddress1").
          with_value('123 Testing Lane')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:CreditCardCity").
          with_value('San Francisco')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:CreditCardState").
          with_value('California')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:CreditCardPostalCode").
          with_value('95611')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:CreditCardHolderName").
          with_value('Example User')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:CreditCardNumber").
          with_value('4111111111111111')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:CreditCardType").
          with_value('Visa')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:CreditCardExpirationMonth").
          with_value('9')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:CreditCardExpirationYear").
          with_value('2018')
      end
    end

    it "masks credit card information" do
      MockResponse.responds_with(:payment_method_credit_card_find_success) do
        pm = Zuora::Objects::PaymentMethod.find('stub')
        pm.credit_card_number.should == '************1111'
      end
    end
  end

  describe "ACH" do
    it "generates proper request xml" do
      MockResponse.responds_with(:payment_method_ach_create_success) do

        FactoryGirl.create(:payment_method_ach, :account => @account)

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:Type").
          with_value('ACH')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:AchAbaCode").
          with_value('123456789')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:AchAccountName").
          with_value('My Checking Account')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:AchBankName").
          with_value('Bank of Zuora')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:AchAccountNumber").
          with_value('987654321')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:AchAccountType").
          with_value('BusinessChecking')
      end
    end

    it "masks bank information" do
      MockResponse.responds_with(:payment_method_ach_find_success) do
        pm = Zuora::Objects::PaymentMethod.find('stub')
        pm.ach_account_number.should == "*****4321"
      end
    end
  end

  describe "PayPal" do
    it "generates proper request xml" do
      MockResponse.responds_with(:payment_method_ach_create_success) do

        FactoryGirl.create(:payment_method_paypal, :account => @account)

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:Type").
          with_value('PayPal')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:PaypalBaid").
          with_value('ExampleBillingAgreementId')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:PaypalEmail").
          with_value('example@example.org')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:PaypalType").
          with_value('ExpressCheckout')
        xml.should_not have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:PaypalPreapprovalKey")
      end
    end
  end

end

