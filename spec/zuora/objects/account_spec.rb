require 'spec_helper'

describe Zuora::Objects::Account do

  it_should_behave_like "ActiveModel"

  it "extends Base object" do
    subject.should be_a_kind_of(Zuora::Objects::Base)
  end

  it "has defined attributes" do
    subject.attributes.keys.map(&:to_s).sort.should ==
      ["account_number", "additional_email_addresses", "allow_invoice_edit", "auto_pay", "balance",
       "batch", "bcd_setting_option", "bill_cycle_day", "bill_to_id", "communication_profile_id",
       "created_by_id", "created_date", "crm_id", "currency", "customer_service_rep_name",
       "default_payment_method_id", "id", "invoice_delivery_prefs_email", "invoice_delivery_prefs_print",
       "invoice_template_id", "last_invoice_date", "name", "notes", "parent_id", "payment_gateway", "payment_term",
       "purchase_order_number", "sales_rep_name", "sold_to_id", "status", "updated_by_id", "updated_date"]
  end

  it "has read only attributes" do
    subject.read_only_attributes.should == [
      :balance, :created_date, :credit_balance, :last_invoice_date, :parent_id, :total_invoice_balance, :updated_date, :created_by_id, :last_invoice_date, :updated_by_id
    ]
  end

  describe "Dirty support" do
    it "handles newly created records" do
      MockResponse.responds_with(:account_create_success) do
        subject.should_not be_name_changed
        subject.name = "Example Account"
        subject.account_number = "abc123"
        subject.currency = 'USD'
        subject.status = 'Draft'
        subject.should be_changed
        subject.changes.keys.sort.should == ["name", "auto_pay", "payment_term", "account_number", "currency", "batch", "bill_cycle_day", "status"].sort
        subject.save.should == true
        subject.should_not be_changed
      end
    end

    it "should consider defaulted attributes dirty for new records" do
      subject.should be_changed
    end
  end

  it "has default values" do
    subject.auto_pay.should == false
    subject.batch.should == 'Batch1'
    subject.bill_cycle_day.should == 1
    subject.payment_term.should == 'Due Upon Receipt'
  end

  it "has a remote model name" do
    subject.remote_name.should == 'Account'
    Zuora::Objects::Account.remote_name.to_s.should == 'Account'
  end

  it "can by casted to a hash" do
    subject.class.new(:id => 42).to_hash.should include({:id => 42})
  end

  describe "creating a remote object" do
    it "should fail and apply errors" do
      MockResponse.responds_with(:account_create_failure) do
        a = Zuora::Objects::Account.new
        a.account_number = 'example-test-10'
        a.name = 'Example Test Account'
        a.batch = 'Batch1'
        a.auto_pay = false
        a.bill_cycle_day = 1
        a.currency = 'USD'
        a.payment_term = 'Due Upon Receipt'
        a.status = 'Draft'
        a.should be_valid
        a.save.should == false
        a.errors[:base].should include('The account number example-test-10 is invalid.')
        a.id.should be_nil
      end
    end
  end

end
