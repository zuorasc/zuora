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
    it "masks credit card information" do
      MockResponse.responds_with(:payment_method_credit_card_find_success) do
        pm = Zuora::Objects::PaymentMethod.find('stub')
        pm.credit_card_number.should == '************1111'
      end
    end
  end

  describe "ACH" do
    it "masks bank information" do
      MockResponse.responds_with(:payment_method_ach_find_success) do
        pm = Zuora::Objects::PaymentMethod.find('stub')
        pm.ach_account_number.should == "*****4321"
      end
    end
  end
end
