require 'spec_helper'

describe Zuora::Config do

  before do
    @config = Zuora::Config.new(:username => 'test', :password => 'example')
  end

  it "provides method access to configuration options" do
    @config.username.should == 'test'
    @config.password.should == 'example'
  end

  it "responds to configuration options" do
    @config.should respond_to(:username)
    @config.should respond_to(:password)
    @config.should_not respond_to(:missing_option)
  end
  
end
