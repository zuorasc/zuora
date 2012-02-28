require 'spec_helper'

describe Zuora::Version do
  it "provides a proper semantic version" do
    Zuora::Version.to_s.should =~ /(\d+\.){2}(\d+)/
  end
end
