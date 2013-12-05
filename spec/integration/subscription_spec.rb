require 'spec_helper'

describe "Subscription" do
  before :each do
    authenticate!
    @account = FactoryGirl.create(:active_account, :account_number => generate_key)
    @product = FactoryGirl.create(:product_catalog, :name => generate_key)
  end

  after :each do
    @account.destroy
    @product.destroy
  end

  it "can be created" do
    payment_method = FactoryGirl.create(:payment_method_credit_card, :account => @account)
    bill_to_contact = @account.contacts.first
    product_rate_plan = @product.product_rate_plans.first
    subscription = FactoryGirl.build(:subscription, :account => @account)

    request = Zuora::Objects::SubscribeRequest.new(
      :account => @account,
      :bill_to_contact => bill_to_contact,
      :payment_method => payment_method,
      :product_rate_plan => product_rate_plan,
      :subscription => subscription
    )

    request.should be_valid
    response = request.create
    response[:success].should == true

    subscriptions = @account.subscriptions
    subscriptions.size.should == 1

    subscription = subscriptions.first
    subscription.should be_valid

    rps = subscription.rate_plans
    rps.size.should == 1
    rp = rps.first
    rp.should be_valid

    rpcs = rp.rate_plan_charges
    rpcs.size.should == 1
    rpcs.first.should be_valid

    @account.invoices.size.should == 1
    invoice = @account.invoices.first
    invoice.invoice_item_adjustments.should == []
    invoice.invoice_items.size.should == 1
    invoice.invoice_adjustments.should == []
  end
end

