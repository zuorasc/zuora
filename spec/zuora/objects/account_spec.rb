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
       "created_by_id", "created_date", "credit_balance","crm_id", "currency", "customer_service_rep_name",
       "default_payment_method_id", "id", "invoice_delivery_prefs_email", "invoice_delivery_prefs_print",
       "invoice_template_id", "last_invoice_date", "name", "notes", "parent_id", "payment_gateway", "payment_term",
       "purchase_order_number", "sales_rep_name", "sold_to_id", "status", "total_invoice_balance", "updated_by_id", "updated_date"]
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

  describe "finding a remote object" do
    it "succeeds" do
      MockResponse.responds_with(:account_find_success) do
        Zuora::Api.instance.should be_authenticated
        account_id = '4028e488348752ce0134876a25867cb2'
        account = Zuora::Objects::Account.find(account_id)
        account.should be_a_kind_of(Zuora::Objects::Account)
        account.id.should == account_id
        account.name.should == 'FooBar'

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:query/#{zns}:queryString").
          with_value(/select .+ from Account where Id = '4028e488348752ce0134876a25867cb2'/)
      end
    end

    it "supports hash based lookups" do
      MockResponse.responds_with(:account_find_success) do
        Zuora::Objects::Account.where(:id => 'test', :name => 'Bob')
        xml = Zuora::Api.instance.last_request
        ns = zuora_namespace('http://api.zuora.com/')
        xml.should have_xml("//env:Body/#{zns}:query/#{zns}:queryString").
          with_value(/select .+ from Account where Id = 'test' and Name = 'Bob'/)
      end
    end
  end

  describe "updating a remote object" do
    it "succeeds" do
      account = nil
      MockResponse.responds_with(:account_find_success) do
        account_id = '4028e488348752ce0134876a25867cb2'
        account = Zuora::Objects::Account.find(account_id)
      end

      MockResponse.responds_with(:account_update_success) do
        old_name = account.name
        account.name = 'FooMax'
        account.should be_changed
        account.name_was.should == old_name
        account.save.should == true
        account.should_not be_changed
      end

      xml = Zuora::Api.instance.last_request
      zns = zuora_namespace('http://api.zuora.com/')
      xml.should have_xml("//env:Body/#{zns}:update/#{zns}:zObjects/#{ons}:Id").
        with_value('4028e488348752ce0134876a25867cb2')
      xml.should have_xml("//env:Body/#{zns}:update/#{zns}:zObjects/#{ons}:Name").
        with_value('FooMax')
    end
  end

  describe "creating a remote object" do
    it "should succeed and set local id" do
      MockResponse.responds_with(:account_create_success) do
        a = Zuora::Objects::Account.new
        a.account_number = 'example-test-10'
        a.name = 'Example Test Account'
        a.batch = 'Batch1'
        a.should be_valid
        a.save.should == true
        a.id.should == '4028e4873491cc7701349574bfcb6af6'

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:Name").
          with_value('Example Test Account')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:Batch").
          with_value('Batch1')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:AutoPay").
          with_value('false')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:BillCycleDay").
          with_value('1')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:Currency").
          with_value('USD')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:PaymentTerm").
          with_value('Due Upon Receipt')
        xml.should have_xml("//env:Body/#{zns}:create/#{zns}:zObjects/#{ons}:Status").
          with_value('Draft')
      end
    end

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

  describe "deleting remote objects" do
    it "should succeed" do
      MockResponse.responds_with(:account_delete_success) do
        id = '4028e4873491cc7701349574bfcb6af6'
        a = Zuora::Objects::Account.new(:id => id)
        a.should be_persisted
        a.destroy.should == true

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:delete/#{zns}:type").
          with_value('Account')
        xml.should have_xml("//env:Body/#{zns}:delete/#{zns}:ids").
          with_value(id)
      end
    end
  end

  describe "querying remote objects" do
    it "returns multiple objects via where" do
      MockResponse.responds_with(:account_query_multiple_success) do
        accounts = Zuora::Objects::Account.where("AccountNumber like 'test%'")
        accounts.size.should == 2
        accounts.map(&:id).sort.should == ['4028e4883491c509013492cd13e2455f','4028e488348752ce0134876a25867cb2'].sort

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:query/#{zns}:queryString").
          with_value(/select .+ from Account where AccountNumber like 'test%'/)
      end
    end
  end

  describe "associations" do
    it "should have many contacts and reflect back" do
      account, contacts, contact = nil, nil, nil

      MockResponse.responds_with(:account_find_success) do
        account = Zuora::Objects::Account.find('4028e488348752ce0134876a25867cb2')
      end

      MockResponse.responds_with(:account_contacts_find_success) do
        contacts = account.contacts
        contacts.size.should == 1
        contact = contacts.first

        xml = Zuora::Api.instance.last_request
        xml.should have_xml("//env:Body/#{zns}:query/#{zns}:queryString").
          with_value(/select .+ from Contact where AccountId = '4028e488348752ce0134876a25867cb2'/)
      end

      MockResponse.responds_with(:account_find_success) do
        contact.account.id.should == account.id
      end
    end
  end
end
