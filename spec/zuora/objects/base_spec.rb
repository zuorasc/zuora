require 'spec_helper'

class SomeExampleObject < Zuora::Objects::Base
end

class SomeExampleConnector
  def initialize(model)
  end
end

describe Zuora::Objects::Base do
  describe :connector do
    it "uses SoapConnector by default" do
      SomeExampleObject.connector.should be_a Zuora::SoapConnector
    end

    it "allows injecting different class for tests" do
      described_class.connector_class = SomeExampleConnector
      SomeExampleObject.connector.should be_a SomeExampleConnector
      #reset for subsequent tests
      described_class.connector_class = Zuora::SoapConnector
    end
  end

  describe :initializer do
    it "allows to overwrite default values" do
      Zuora::Objects::Invoice.new.includes_usage.should be_true
      Zuora::Objects::Invoice.new(:includes_usage => false).includes_usage.should be_false
    end

    it "assigns attributes from passed in hash" do
      Zuora::Objects::Account.new(:name => "Test Name").name.should == "Test Name"
    end
  end

  describe "attributes=" do
    it "should assign attributes to an existing instance from passed in hash" do
      account = Zuora::Objects::Account.new(:name => "Test Name")
      account.attributes = {:name => "New Name"}
      account.name.should == "New Name"
    end
  end
end
