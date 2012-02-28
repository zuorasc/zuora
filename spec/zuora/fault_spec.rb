require 'spec_helper'

describe Zuora::Fault do

  it "is an exception" do
    subject.should be_a_kind_of(StandardError)
  end

  it "has required attributes" do
    [:string, :code, :message].each do |attr|
      subject.should respond_to(attr)
    end
  end

  it "can be instantiated and read" do
    fault = Zuora::Fault.new(
      :string  => 'Invalid login. User name and password do not match.',
      :message => 'Invalid login. User name and password do not match.',
      :code    => 'INVALID_VALUE')

    fault.code.should    == 'INVALID_VALUE'
    fault.message.should == 'Invalid login. User name and password do not match.'
    fault.string.should  == 'Invalid login. User name and password do not match.'
  end

  it "returns message for to_s" do
    fault = Zuora::Fault.new(:message => 'This is an example failure.')
    fault.to_s.should == 'This is an example failure.'
  end
end
