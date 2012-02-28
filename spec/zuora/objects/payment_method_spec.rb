require 'spec_helper'

describe Zuora::Objects::PaymentMethod do
  before :each do
    @account = mock(Zuora::Objects::Account, :id => 1)
  end

  describe "Type helpers" do
    it "supports credit_card?" do
      Factory.build(:payment_method_credit_card).should be_credit_card
    end

    it "supports ach?" do
      Factory.build(:payment_method_ach).should be_ach
    end

    it "supports paypal?" do
      Factory.build(:payment_method_paypal).should be_paypal
    end

    it "supports debit_card?" do
      Factory.build(:payment_method_debit_card).should be_debit_card
    end

    it "supports card?" do
      Factory.build(:payment_method_credit_card).should be_card
      Factory.build(:payment_method_debit_card).should be_card
    end
  end

  describe "write only attributes" do
    ach = Factory.build(:payment_method_ach)
    ach.write_only_attributes.should == [:ach_account_number, :credit_card_number,
      :credit_card_security_code, :gateway_option_data, :skip_validation]
  end

  describe "Credit Card" do
    it "generates proper request xml" do
      MockResponse.responds_with(:payment_method_credit_card_create_success) do
        
        Factory.create(:payment_method_credit_card, :account => @account)

        xml = Zuora::Api.instance.last_request
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:Type').
          with_value('CreditCard')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:CreditCardAddress1').
          with_value('123 Testing Lane')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:CreditCardCity').
          with_value('San Francisco')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:CreditCardState').
          with_value('California')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:CreditCardPostalCode').
          with_value('95611')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:CreditCardHolderName').
          with_value('Example User')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:CreditCardNumber').
          with_value('4111111111111111')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:CreditCardType').
          with_value('Visa')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:CreditCardExpirationMonth').
          with_value('9')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:CreditCardExpirationYear').
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

        Factory.create(:payment_method_ach, :account => @account)

        xml = Zuora::Api.instance.last_request
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:Type').
          with_value('ACH')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:AchAbaCode').
          with_value('123456789')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:AchAccountName').
          with_value('My Checking Account')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:AchBankName').
          with_value('Bank of Zuora')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:AchAccountNumber').
          with_value('987654321')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:AchAccountType').
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

        Factory.create(:payment_method_paypal, :account => @account)

        xml = Zuora::Api.instance.last_request
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:Type').
          with_value('PayPal')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:PaypalBaid').
          with_value('ExampleBillingAgreementId')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:PaypalEmail').
          with_value('example@example.org')
        xml.should have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:PaypalType').
          with_value('ExpressCheckout')
        xml.should_not have_xml('//env:Body/ins0:create/ins0:zObjects/ins2:PaypalPreapprovalKey')
      end
    end
  end

end

