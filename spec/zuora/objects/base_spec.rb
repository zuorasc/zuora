require 'spec_helper'

class ExampleObject < Zuora::Objects::Base
end

class ExampleConnector
  def initialize(model)
  end
end

describe Zuora::Objects::Base do
  describe :connector do
    it "uses SoapConnector by default" do
      ExampleObject.connector.should be_a Zuora::SoapConnector
    end

    it "allows injecting different class for tests" do
      described_class.connector_class = ExampleConnector
      ExampleObject.connector.should be_a ExampleConnector
      #reset for subsequent tests
      described_class.connector_class = Zuora::SoapConnector
    end
  end
end
