require 'spec_helper'

describe Zuora::Session do

  before do
    @result_hash = {:login_response=>{:"@xmlns:ns1"=>"http://api.zuora.com/", :result=>{:session=>"session_key", :server_url=>"https://www.zuora.com/apps/services/a/36.0"}}}
  end

  it "has key and server_url" do
    subject.should respond_to(:key)
    subject.should respond_to(:server_url)
  end

  it "can be generated from result hash" do
    session = Zuora::Session.generate(@result_hash)
    session.key.should == 'session_key'
    session.server_url.should == 'https://www.zuora.com/apps/services/a/36.0'
  end

  it "should set a default expiry of 10 minutes" do
    session = Zuora::Session.generate(@result_hash)
    session.should_not be_expired
    session.should be_active
    session.expires_at.should be_within(2).of(Time.now + 600)
  end

  it "should be expired" do
    session = Zuora::Session.generate(@result_hash)
    session.expires_at = Time.now - 1 
    session.should be_expired
    session.should_not be_active
  end

end

